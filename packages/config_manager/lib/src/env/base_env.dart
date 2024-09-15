/// Interface for the environment fields of the app.
abstract class BaseEnv {
  /// The name of the app.
  abstract final String? appName;

  /// The base api URL of the app.
  abstract final String? baseApiUrl;

  /// The Sentry DSN of the app.
  abstract final String? sentryDSN;
}
