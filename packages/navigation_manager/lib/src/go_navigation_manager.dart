import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_manager/log_manager.dart';

import 'models/navigation_state.dart';
import 'models/route_config.dart';
import 'navigation_manager.dart';

/// A navigation manager that uses the GoRouter package.
class GoNavigationManager implements NavigationManager {
  /// Constructs a new navigation manager
  /// with the given routes and initial location.
  GoNavigationManager({
    required List<RouteConfig> routes,
    required String initialLocation,
    String? restorationScopeId,
    NavigationErrorBuilder? errorBuilder,
    LogManager? logManager,
  }) : _logManager = logManager {
    _logManager?.lInfo(
      '''Initializing GoNavigationManager with initial location: $initialLocation''',
    );
    _router = GoRouter(
      routes: _convertRoutes(routes),
      initialLocation: initialLocation,
      navigatorKey: _rootNavigatorKey,
      restorationScopeId: restorationScopeId,
      debugLogDiagnostics: true,
      redirect: _globalRedirect,
      errorBuilder: (BuildContext context, GoRouterState state) {
        _logManager?.lInfo('Error occurred: ${state.error}');
        return (errorBuilder ?? defaultNavigationErrorBuilder)
            .call(context, state.error);
      },
    );
  }

  final LogManager? _logManager;
  late final GoRouter _router;

  /// The GoRouter instance used by this manager.
  @override
  GoRouter get router => _router;

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  List<RouteBase> _convertRoutes(List<RouteConfig> routes) {
    return routes
        .map(
          (RouteConfig config) => GoRoute(
            path: config.path,
            name: config.name,
            builder: (BuildContext context, GoRouterState state) =>
                config.builder(context, NavigationState.fromGoState(state)),
          ),
        )
        .toList();
  }

  FutureOr<String?> _globalRedirect(BuildContext context, GoRouterState state) {
    // Implement global redirect logic here
    return null;
  }

  @override
  Future<void> refresh() async {
    final RouteMatchList c = _router.routerDelegate.currentConfiguration;
    final RouteBase lastRoute = c.routes.last;
    final String? currentName = lastRoute is GoRoute ? lastRoute.name : null;
    if (currentName == null) return;
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
    return _router.pushReplacement<T>(path, extra: extra);
  }

  @override
  void pop<T extends Object?>([T? result]) {
    _logManager?.lInfo('Popping route with result: $result');
    _router.pop(result);
  }

  @override
  bool canPop() {
    return _router.canPop();
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
    _logManager?.lInfo('Popping until condition met with name: $name');
    bool defaultPredicate(Route<Object?> route) {
      if (route.isFirst) {
        if (pushIfNotExists && name != null) {
          replaceWithNamed(name);
          return true;
        }
        if (avoidLastPop) return true;
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
    Object? extra,
    NavigationPredicateCallback? predicate,
  }) async {
    _logManager?.lInfo('Pushing named and removing until path: $path');
    await _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      path,
      predicate ?? (Route<Object?> route) => false,
      arguments: extra,
    );
  }

  @override
  void dispose() {
    _logManager?.lInfo('Disposing GoNavigationManager');
  }

  /// Sets the default navigation error builder.
  @override
  Widget defaultNavigationErrorBuilder(
    BuildContext context,
    Exception? exception,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(exception?.toString() ?? 'An unknown error occurred.'),
      ),
    );
  }
}
