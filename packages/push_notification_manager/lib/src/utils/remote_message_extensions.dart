import 'package:firebase_messaging/firebase_messaging.dart';

/// Extension methods for [RemoteMessage].
extension RemoteMessageExtensions on RemoteMessage {
  /// Converts [RemoteMessage] to a complete map.
  Map<String, dynamic> get toCompleteMap => <String, dynamic>{
        'data': data,
        'notification': notification,
        'title': notification?.title,
        'body': notification?.body,
        'messageId': messageId,
        'sentTime': sentTime,
        'ttl': ttl,
      };
}
