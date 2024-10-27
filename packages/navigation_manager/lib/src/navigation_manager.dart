import 'package:flutter/material.dart';

/// Navigation error builder function signature.
typedef NavigationErrorBuilder = Widget Function(
  BuildContext context,
  Exception? exception,
);

/// Navigation predicate callback signature.
typedef NavigationPredicateCallback = bool Function(Route<Object?>);

/// Abstract class defining the contract for navigation services.
abstract interface class NavigationManager {
  /// Navigate to a named route.
  Future<T?> navigateToNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Navigate to a specific path.
  Future<T?> navigateTo<T extends Object?>(String path, {Object? extra});

  /// Replace the current route with a named route.
  Future<T?> replaceWithNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Replace the current route with a specific path.
  Future<T?> replaceWith<T extends Object?>(String path, {Object? extra});

  /// Pop the current route off the navigation stack.
  bool pop<T extends Object?>([T? result]);

  /// Check if it's possible to pop the current route.
  bool canPop();

  /// Get the current route information
  RouteInformation get currentRoute;

  /// Refresh the current route
  Future<void> refresh();

  /// Navigates to the path. It's difference from the [navigateTo] method:
  /// it doesn't push the route to the navigation stack. It's like a redirect.
  void replaceAllAndGo(String path, {Object? extra});

  /// Navigates to the named route. It's difference from the [navigateToNamed]
  /// method: it doesn't push the route to the navigation stack. Instead,
  /// it replaces the current route.
  void replaceAllAndGoNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Pop the route stack until the predicate returns true,
  /// uses the named route.
  void popUntil({
    String? name,
    NavigationPredicateCallback? predicate,
    bool pushIfNotExists = true,
    bool avoidLastPop = true,
  });

  /// Navigates to the given path and pushes it to the stack and removes all
  /// the routes until the predicate returns true.
  Future<void> pushNamedAndRemoveUntil(
    String path, {
    Object? extra,
    NavigationPredicateCallback? predicate,
  });

  /// Dispose of the NavigationService
  void dispose();

  /// The router configuration for the navigation manager.
  RouterConfig<Object>? get router;
}
