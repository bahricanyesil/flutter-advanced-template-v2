import '../../navigation_manager.dart';

/// Configuration for a shell route.
///
/// This class extends [RouteConfig] and adds a [builder] parameter
/// for the shell builder function.
base class ShellRouteConfig extends RouteConfig {
  /// Creates a new [ShellRouteConfig] instance.
  const ShellRouteConfig({
    required super.builder,
    required super.routes,
    required super.path,
    super.name,
    super.pageBuilder,
    super.redirect,
    super.parentNavigatorKey,
    super.onExit,
  });
}
