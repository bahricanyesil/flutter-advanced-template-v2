import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';

final class MockNotificationResponse extends Mock
    implements NotificationResponse {
  @override
  NotificationResponseType get notificationResponseType =>
      NotificationResponseType.selectedNotificationAction;
}
