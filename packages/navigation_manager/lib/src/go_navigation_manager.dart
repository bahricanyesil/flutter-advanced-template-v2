import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_manager/log_manager.dart';

import 'models/navigation_state.dart';
import 'models/route_config.dart';
import 'navigation_manager.dart';

/// A custom exception handler that takes a [BuildContext], [NavigationState],
/// and [RouterConfig] as arguments.
typedef CustomExceptionHandler = void Function(
  BuildContext context,
  NavigationState state,
  RouterConfig<Diagnosticable> router,
);

/// A custom error page builder that takes a [BuildContext] and
/// [NavigationState] as arguments.
typedef CustomErrorPageBuilder = Page<Object?> Function(
  BuildContext context,
  NavigationState state,
);

/// A navigation manager that uses the GoRouter package.
class GoNavigationManager implements NavigationManager {
  /// Constructs a new navigation manager
  /// with the given routes and initial location.
  GoNavigationManager({
    required List<RouteConfig> routes,
    required String initialLocation,
    String? restorationScopeId,
    NavigationErrorBuilder? errorBuilder,
    CustomRedirectCallback? redirect,
    bool requestFocus = true,
    CustomExceptionHandler? exceptionHandler,
    bool debugLogDiagnostics = true,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    Object? initialExtra,
    bool routerNeglect = false,
    int maxRedirects = 5,
    Codec<Object?, Object?>? extraCodec,
    Listenable? refreshListenable,
    bool overridePlatformDefaultLocation = false,
    CustomErrorPageBuilder? errorPageBuilder,
    LogManager? logManager,
  }) : _logManager = logManager {
    _logManager?.lInfo(
      '''Initializing GoNavigationManager with initial location: $initialLocation''',
    );
    final GoRouter goRouter = GoRouter(
      routes: _convertRoutes(routes),
      initialLocation: initialLocation,
      navigatorKey: _rootNavigatorKey,
      restorationScopeId: restorationScopeId,
      debugLogDiagnostics: debugLogDiagnostics,
      requestFocus: requestFocus,
      initialExtra: initialExtra,
      redirectLimit: maxRedirects,
      extraCodec: extraCodec,
      refreshListenable: refreshListenable,
      overridePlatformDefaultLocation: overridePlatformDefaultLocation,
      routerNeglect: routerNeglect,
      errorPageBuilder: errorPageBuilder == null
          ? null
          : (BuildContext context, GoRouterState state) {
              _logManager?.lInfo('Error occurred: ${state.error}');
              return errorPageBuilder.call(
                context,
                NavigationState.fromGoState(state),
              );
            },
      onException: exceptionHandler == null
          ? null
          : (BuildContext c, GoRouterState s, GoRouter r) {
              _logManager?.lInfo('Exception occurred: ${s.error}');
              final NavigationState navigationS =
                  NavigationState.fromGoState(s);
              return exceptionHandler.call(c, navigationS, r);
            },
      observers: observers,
      redirect: redirect == null
          ? null
          : (BuildContext context, GoRouterState state) {
              _logManager?.lInfo('Redirecting to: $state');
              return redirect.call(context, NavigationState.fromGoState(state));
            },
      errorBuilder: errorBuilder == null
          ? null
          : (BuildContext context, GoRouterState state) {
              _logManager?.lInfo('Error occurred: ${state.error}');
              return errorBuilder.call(context, state.error);
            },
    );
    _router = goRouter;
  }

  final LogManager? _logManager;
  late final GoRouter _router;

  /// The GoRouter instance used by this manager.
  @override
  GoRouter get router => _router;

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  List<RouteBase> _convertRoutes(List<RouteConfig> routes) {
    return routes.map(
      (RouteConfig config) {
        final CustomPageBuilder? customPageBuilder = config.pageBuilder;
        final CustomOnExitCallback? onExit = config.onExit;
        final CustomRedirectCallback? redirect = config.redirect;
        return GoRoute(
          path: config.path,
          name: config.name,
          pageBuilder: customPageBuilder == null
              ? null
              : (BuildContext context, GoRouterState state) => customPageBuilder
                  .call(context, NavigationState.fromGoState(state)),
          onExit: onExit == null
              ? null
              : (BuildContext context, GoRouterState state) =>
                  onExit.call(context, NavigationState.fromGoState(state)),
          parentNavigatorKey: config.parentNavigatorKey,
          redirect: redirect == null
              ? null
              : (BuildContext context, GoRouterState state) =>
                  redirect.call(context, NavigationState.fromGoState(state)),
          routes: _convertRoutes(config.routes),
          builder: (BuildContext context, GoRouterState state) =>
              config.builder(context, NavigationState.fromGoState(state)),
        );
      },
    ).toList();
  }

  @override
  Future<void> refresh() async {
    final RouteMatchList c = _router.routerDelegate.currentConfiguration;
    final RouteBase lastRoute = c.routes.last;
    final String? currentName = lastRoute is GoRoute ? lastRoute.name : null;
    if (currentName == null) return;
    _logManager?.lInfo('Refreshing route: $currentName');
    await replaceWithNamed((c.routes.last as GoRoute).name ?? '');
  }

  @override
  Future<T?> navigateToNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    _logManager?.lInfo(
      '''Navigating to named route: $name with params: $params and queryParams: $queryParams''',
    );
    return _router.pushNamed<T>(
      name,
      pathParameters: params,
      queryParameters: queryParams,
      extra: extra,
    );
  }

  @override
  Future<T?> navigateTo<T extends Object?>(String path, {Object? extra}) {
    _logManager?.lInfo('Navigating to path: $path');
    return _router.push<T>(path, extra: extra);
  }

  @override
  Future<T?> replaceWithNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) async {
    _logManager?.lInfo('Replacing with named route: $name');
    return _router.pushReplacementNamed<T>(
      name,
      pathParameters: params,
      queryParameters: queryParams,
      extra: extra,
    );
  }

  @override
  Future<T?> replaceWith<T extends Object?>(
    String path, {
    Object? extra,
  }) async {
    _logManager?.lInfo('Replacing with path: $path');
    return _router.pushReplacement<T>(path, extra: extra);
  }

  @override
  bool pop<T extends Object?>([T? result]) {
    if (!canPop()) return false;
    _logManager?.lInfo('Popping route with result: $result');
    _router.pop(result);
    return true;
  }

  @override
  bool canPop() {
    _logManager?.lInfo('Checking if can pop');
    final bool canPopRes = _router.canPop();
    _logManager?.lInfo('Can pop: $canPopRes');
    return canPopRes;
  }

  @override
  RouteInformation get currentRoute => _router.routeInformationProvider.value;

  /// Navigates to the given path and pushes it to the stack.
  @override
  void replaceAllAndGo(String path, {Object? extra}) {
    _logManager?.lInfo('Replacing all and going to path: $path');
    _router.go(path, extra: extra);
  }

  /// Navigates to the named route and replaces the current route.
  @override
  void replaceAllAndGoNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    _logManager?.lInfo('Replacing all and going to named route: $name');
    _router.goNamed(
      name,
      pathParameters: params,
      queryParameters: queryParams,
      extra: extra,
    );
  }

  /// Pops routes until the predicate returns true.
  @override
  void popUntil({
    String? name,
    NavigationPredicateCallback? predicate,
    bool pushIfNotExists = true,
    bool avoidLastPop = true,
  }) {
    assert(name != null || predicate != null, 'Name or predicate must be set');
    _logManager?.lInfo('Popping until condition met with name: $name');
    bool defaultPredicate(Route<Object?> route) {
      if (route.isFirst) {
        if (pushIfNotExists && name != null) {
          _logManager?.lInfo('Pushing named route: $name');
          replaceWithNamed(name);
          return true;
        }
        if (avoidLastPop) {
          _logManager?.lInfo('Avoiding last pop');
          return true;
        }
      }
      return route.settings.name?.toLowerCase() == name?.toLowerCase();
    }

    _rootNavigatorKey.currentState?.popUntil(predicate ?? defaultPredicate);
  }

  /// Navigates to the given path and pushes it to the stack and removes all
  /// the routes until the predicate returns true.
  @override
  Future<void> pushNamedAndRemoveUntil(
    String path, {
    String? untilScreenName,
    Object? extra,
    NavigationPredicateCallback? predicate,
  }) async {
    _logManager?.lInfo('Pushing named and removing until path: $path');
    bool defaultPredicate(Route<Object?> route) =>
        route.settings.name?.toLowerCase() == untilScreenName?.toLowerCase();
    await _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      path,
      predicate ?? defaultPredicate,
      arguments: extra,
    );
  }

  @override
  Future<void> popOnceOrPushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) async {
    _logManager?.lInfo('Checking if previous route matches: $name');
    bool routeMatches = false;

    // Check if the previous route matches the given route name
    final List<Page<Object?>>? routes =
        _rootNavigatorKey.currentState?.widget.pages;
    if (routes != null && routes.length > 1) {
      final Page<Object?> previousRoute = routes[routes.length - 2];
      if (previousRoute.name?.toLowerCase() == name.toLowerCase()) {
        routeMatches = true;
      }
    }

    if (routeMatches) {
      _logManager
          ?.lInfo('Previous route matches, popping once to route: $name');
      pop();
    } else {
      _logManager
          ?.lInfo('Previous route does not match, pushing new route: $name');
      await navigateToNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );
    }
  }

  @override
  Future<void> popUntilOrPushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) async {
    _logManager?.lInfo('Checking if route exists: $name');
    bool routeExists = false;

    // Check if the route exists in the stack without popping
    final List<Page<Object?>>? routes =
        _rootNavigatorKey.currentState?.widget.pages;
    if (routes != null) {
      for (final Page<Object?> route in routes) {
        if (route.name?.toLowerCase() == name.toLowerCase()) {
          routeExists = true;
          break;
        }
      }
    }

    if (routeExists) {
      _logManager?.lInfo('Route found in stack, popping until route: $name');
      _rootNavigatorKey.currentState?.popUntil((Route<Object?> route) {
        return route.settings.name?.toLowerCase() == name.toLowerCase();
      });
      popUntil(name: name);
    } else {
      _logManager?.lInfo('Route not found in stack, pushing new route: $name');
      await navigateToNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );
    }
  }

  @override
  void dispose() {
    _logManager?.lInfo('Disposing GoNavigationManager');
  }
}
