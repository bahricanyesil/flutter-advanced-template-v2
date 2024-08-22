import 'package:analytics_manager/src/firebase_analytics_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';


/// A class that provides dependency injection for the [FirebaseAnalyticsManager] class.
/// It registers a named instance of [FirebaseAnalyticsManager]
/// using the [GetIt] service locator.
/// The [FirebaseAnalyticsManager] instance is created using the [FirebaseAnalytics] and [LogManager] instances.
abstract final class AnalyticsManagerDI {
  static final GetIt _getIt = GetIt.instance;

  /// Initializes the dependencies for [FirebaseAnalyticsManager].
  static Future<void> initialize() async {
    if (!_getIt.isRegistered<LogManager>()) {
      throw Exception(
        'LogManager is not registered. Please initialize LogManager before FirebaseAnalyticsManager.',
      );
    }

    if (!_getIt.isRegistered<FirebaseAnalytics>()) {
      // Register FirebaseAnalytics if not already registered
      _getIt
          .registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics());
    }

    if (!_getIt.isRegistered<FirebaseAnalyticsManager>(
      instanceName: 'firebaseAnalyticsManager',
    )) {
      final FirebaseAnalytics firebaseAnalytics = _getIt<FirebaseAnalytics>();
      final FirebaseAnalyticsManager firebaseAnalyticsManager =
          await FirebaseAnalyticsManager.create(firebaseAnalytics);
      _getIt.registerLazySingleton<FirebaseAnalyticsManager>(
        () => firebaseAnalyticsManager,
        instanceName: 'firebaseAnalyticsManager',
      );
    }
  }

  /// Returns the [FirebaseAnalyticsManager] instance by name.
  static FirebaseAnalyticsManager get firebaseAnalyticsManager {
    try {
      return _getIt<FirebaseAnalyticsManager>(
        instanceName: 'firebaseAnalyticsManager',
      );
    } catch (e) {
      throw Exception('FirebaseAnalyticsManager is not registered.');
    }
  }
}

/// Configures the dependencies for the FirebaseAnalyticsManager.
Future<void> configureAnalyticsManagerDependencies() async {
  await AnalyticsManagerDI.initialize();
}
