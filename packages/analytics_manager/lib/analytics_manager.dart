/// Library for analytics manager that
/// provides a unified interface for logging events and screens.
///
/// This library provides an abstract class AnalyticsManager that
/// defines the methods for logging events and screens.
///
/// The library also provides a concrete implementation of the
/// AnalyticsManager interface using Firebase Analytics.
/// This implementation is available in the FirebaseAnalyticsManager class.
library analytics_manager;

export 'package:analytics_manager/src/analytics_manager.dart';
export 'package:analytics_manager/src/firebase_analytics_manager.dart';
