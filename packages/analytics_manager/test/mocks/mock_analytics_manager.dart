import 'package:analytics_manager/analytics_manager.dart';

final class MockAnalyticsManager extends AnalyticsManager {
  const MockAnalyticsManager({super.logManager});

  @override
  Future<void> init() async {}

  @override
  void dispose() {}

  @override
  Future<void> resetAnalyticsData() async {}

  @override
  Future<void> enableAnalytics() async {}

  @override
  Future<void> disableAnalytics() async {}

  @override
  Future<bool> isAnalyticsEnabled() async {
    return true;
  }
}
