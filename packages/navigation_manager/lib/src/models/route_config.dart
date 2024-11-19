// import 'dart:async';

// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';

// import '../../navigation_manager.dart';

// /// A function that builds a page for a route.
// typedef CustomPageBuilder = Page<Object?> Function(
//   BuildContext context,
//   NavigationState state, {
//   Widget? child,
// });

// /// Route builder function.
// typedef CustomRouteBuilder = Widget Function(
//   BuildContext context,
//   NavigationState state, {
//   Widget? child,
// });

// /// Redirect callback function.
// typedef CustomRedirectCallback = FutureOr<String?> Function(
//   BuildContext context,
//   NavigationState state,
// );

// /// Exit route callback function.
// typedef CustomOnExitCallback = FutureOr<bool> Function(
//   BuildContext context,
//   NavigationState state,
// );

// /// Configuration for a single route
// ///
// /// This class holds the configuration for a route, including its path,
// /// name, and a builder function that returns a widget for the route.
// base class RouteConfig extends Equatable {
//   /// Creates a new [RouteConfig] instance.
//   ///
//   /// The [path] and [builder] parameters are required.
//   /// The [name] parameter is optional.
//   const RouteConfig({
//     required this.path,
//     required this.builder,
//     this.name,
//     this.pageBuilder,
//     this.onExit,
//     this.parentNavigatorKey,
//     this.redirect,
//     this.routes = const <RouteConfig>[],
//     this.observers,
//   });

//   /// The path of the route.
//   ///
//   /// This is a required parameter and represents the URL path for the route.
//   final String path;

//   /// The name of the route.
//   ///
//   /// This is an optional parameter and can be used to give a name to the route.
//   final String? name;

//   /// The builder function for the route.
//   ///
//   /// This function takes a [BuildContext] and a map of string parameters,
//   /// and returns a [Widget] for the route.
//   final CustomRouteBuilder builder;

//   /// The page builder function for the route.
//   ///
//   /// This function takes a [BuildContext] and a [NavigationState],
//   /// and returns a [Page] for the route.
//   final CustomPageBuilder? pageBuilder;

//   /// The parent navigator key for the route.
//   ///
//   /// This is an optional parameter and can be used to specify
//   /// a parent navigator for the route.
//   final GlobalKey<NavigatorState>? parentNavigatorKey;

//   /// The redirect callback for the route.
//   ///
//   /// This is an optional parameter and can be used to specify a redirect
//   /// callback for the route.
//   final CustomRedirectCallback? redirect;

//   /// The onEnter callback for the route.
//   ///
//   /// This is an optional parameter and can be used to specify an onEnter
//   /// callback for the route.
//   final CustomOnExitCallback? onExit;

//   /// The onExit callback for the route.
//   ///
//   /// This is an optional parameter and can be used to specify an onExit
//   /// callback for the route.
//   final List<RouteConfig> routes;

//   /// The observers for the route.
//   ///
//   /// This is an optional parameter and can be used to specify observers
//   /// for the route.
//   final List<NavigatorObserver>? observers;

//   @override
//   List<Object?> get props => <Object?>[
//         path,
//         name,
//         builder,
//         routes,
//         parentNavigatorKey,
//         redirect,
//         onExit,
//         pageBuilder,
//         observers,
//       ];
// }
