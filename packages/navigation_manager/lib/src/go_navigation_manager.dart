import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_manager/log_manager.dart';

import 'navigation_manager.dart';

// /// A custom exception handler that takes a [BuildContext], [NavigationState],
// /// and [RouterConfig] as arguments.
// typedef CustomExceptionHandler = void Function(
//   BuildContext context,
//   NavigationState state,
//   RouterConfig<Diagnosticable> router,
// );

// /// A custom error page builder that takes a [BuildContext] and
// /// [NavigationState] as arguments.
// typedef CustomErrorPageBuilder = Page<Object?> Function(
//   BuildContext context,
//   NavigationState state,
// );

// /// A callback function that builds a page for a route.
// typedef PageBuilderCallback = Page<Object?> Function(
//   BuildContext context,
//   GoRouterState state,
//   Widget child,
// );

/// A navigation manager that uses the GoRouter package.
class GoNavigationManager implements NavigationManager {
  /// Constructs a new navigation manager
  /// with the given routes and initial location.
  GoNavigationManager({
    // required List<RouteConfig> routes,
    required List<RouteBase> routes,
    required String initialLocation,
    String? restorationScopeId,
    NavigationErrorBuilder? errorBuilder,
    GoRouterRedirect? redirect,
    bool requestFocus = true,
    GoExceptionHandler? exceptionHandler,
    bool debugLogDiagnostics = true,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    Object? initialExtra,
    bool routerNeglect = false,
    int maxRedirects = 5,
    Codec<Object?, Object?>? extraCodec,
    Listenable? refreshListenable,
    bool overridePlatformDefaultLocation = false,
    GoRouterPageBuilder? errorPageBuilder,
    LogManager? logManager,
  }) : _logManager = logManager {
    _logManager?.lInfo(
      '''Initializing GoNavigationManager with initial location: $initialLocation''',
    );
    final GoRouter goRouter = GoRouter(
      // routes: _convertRoutes(routes),
      routes: routes,
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
      observers: observers,
      redirect: redirect,
      onException: exceptionHandler,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder == null
          ? null
          : (BuildContext context, GoRouterState state) {
              _logManager?.lInfo('Error occurred: ${state.error}');
              return errorBuilder.call(context, state.error);
            },
      // errorPageBuilder: errorPageBuilder == null
      //     ? null
      //     : (BuildContext context, GoRouterState state) {
      //         _logManager?.lInfo('Error occurred: ${state.error}');
      //         return errorPageBuilder.call(
      //           context,
      //           NavigationState.fromGoState(state),
      //         );
      //       },
      // onException: exceptionHandler == null
      //     ? null
      //     : (BuildContext c, GoRouterState s, GoRouter r) {
      //         _logManager?.lInfo('Exception occurred: ${s.error}');
      //         final NavigationState navigationS =
      //             NavigationState.fromGoState(s);
      //         return exceptionHandler.call(c, navigationS, r);
      //       },
      // redirect: redirect == null
      //     ? null
      //     : (BuildContext context, GoRouterState state) {
      //         _logManager?.lInfo('Redirecting to: $state');
      //         return redirect.call(context,
      //             NavigationState.fromGoState(state));
      //       },
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

  // List<RouteBase> _convertRoutes(List<RouteConfig> routes) {
  //   return routes.map(
  //     (RouteConfig config) {
  //       final CustomRedirectCallback? redirect = config.redirect;
  //       final FutureOr<String?> Function(BuildContext, GoRouterState)?
  //           redirectCallback = redirect == null
  //               ? null
  //               : (BuildContext context, GoRouterState state) =>
  //                   redirect.call(context,
  //                    NavigationState.fromGoState(state));

  //       final CustomPageBuilder? customPageBuilder = config.pageBuilder;
  //       final CustomOnExitCallback? onExit = config.onExit;

  //       if (config is ShellRouteConfig) {
  //         final PageBuilderCallback? pageBuilder = customPageBuilder == null
  //             ? null
  //             : (BuildContext context, GoRouterState state, Widget child) =>
  //                 customPageBuilder.call(
  //                   context,
  //                   NavigationState.fromGoState(state),
  //                   child: child,
  //                 );
  //         return ShellRoute(
  //           builder: (BuildContext context, GoRouterState state,
  //                 Widget child) {
  //             return config.builder(
  //               context,
  //               NavigationState.fromGoState(state),
  //               child: child,
  //             );
  //           },
  //           routes: _convertRoutes(config.routes),
  //           parentNavigatorKey: config.parentNavigatorKey,
  //           observers: config.observers,
  //           redirect: redirectCallback,
  //           pageBuilder: pageBuilder,
  //         );
  //       }

  //       return GoRoute(
  //         path: config.path,
  //         name: config.name,
  //         pageBuilder: customPageBuilder == null
  //             ? null
  //             : (BuildContext context, GoRouterState state) =>
  //                  customPageBuilder
  //                 .call(context, NavigationState.fromGoState(state)),
  //         onExit: onExit == null
  //             ? null
  //             : (BuildContext context, GoRouterState state) =>
  //                 onExit.call(context, NavigationState.fromGoState(state)),
  //         parentNavigatorKey: config.parentNavigatorKey,
  //         redirect: redirectCallback,
  //         routes: _convertRoutes(config.routes),
  //         builder: (BuildContext context, GoRouterState state) =>
  //             config.builder(context, NavigationState.fromGoState(state)),
  //       );
  //     },
  //   ).toList();
  // }

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
    String name, {
    String? untilScreenName,
    Object? extra,
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    NavigationPredicateCallback? predicate,
  }) async {
    _logManager?.lInfo('Pushing named and removing until name: $name');
    popUntil(
      name: untilScreenName,
      predicate: predicate ?? (Route<Object?> route) => route.isFirst,
      pushIfNotExists: false,
    );
    await replaceWithNamed(
      name,
      extra: extra,
      params: params,
      queryParams: queryParams,
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
