import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tuna_lojistik/core/managers/navigation_manager/models/navigation_state.dart';

/// Configuration for a single route
///
/// This class holds the configuration for a route, including its path,
/// name, and a builder function that returns a widget for the route.
base class RouteConfig extends Equatable {
  /// Creates a new [RouteConfig] instance.
  ///
  /// The [path] and [builder] parameters are required.
  /// The [name] parameter is optional.
  const RouteConfig({
    required this.path,
    required this.builder,
    this.name,
  });

  /// The path of the route.
  ///
  /// This is a required parameter and represents the URL path for the route.
  final String path;

  /// The name of the route.
  ///
  /// This is an optional parameter and can be used to give a name to the route.
  final String? name;

  /// The builder function for the route.
  ///
  /// This function takes a [BuildContext] and a map of string parameters,
  /// and returns a [Widget] for the route.
  final Widget Function(BuildContext, NavigationState) builder;

  @override
  List<Object?> get props => <Object?>[path, name, builder];
}
