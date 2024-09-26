import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// The state of the navigation.
base class NavigationState extends Equatable {
  /// Default constructor for creating route state during routing.
  const NavigationState({
    required this.uri,
    required this.matchedLocation,
    required this.pathParameters,
    required this.pageKey,
    this.fullPath,
    this.name,
    this.path,
    this.extra,
    this.error,
  });

  /// Creates a new [NavigationState] from a [GoRouterState].
  factory NavigationState.fromGoState(GoRouterState state) => NavigationState(
        uri: state.uri,
        matchedLocation: state.matchedLocation,
        fullPath: state.fullPath,
        pathParameters: state.pathParameters,
        pageKey: state.pageKey,
        error: state.error,
        name: state.name,
        extra: state.extra,
        path: state.path,
      );

  /// The full uri of the route, e.g. /family/f2/person/p1?filter=name#fragment
  final Uri uri;

  /// The matched location until this point.
  final String matchedLocation;

  /// The full path to this sub-route, e.g. /family/:fid
  final String? fullPath;

  /// The parameters for this match, e.g. {'fid': 'f2'}
  final Map<String, String> pathParameters;

  /// The key of the page.
  final ValueKey<String> pageKey;

  /// The optional name of the route associated with this app.
  final String? name;

  /// The path of the route associated with this app. e.g. family/:fid
  final String? path;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// The error associated with this sub-route.
  final Exception? error;

  @override
  List<Object?> get props => <Object?>[
        uri,
        matchedLocation,
        fullPath,
        pathParameters,
        pageKey,
        name,
        path,
        extra,
        error,
      ];
}
