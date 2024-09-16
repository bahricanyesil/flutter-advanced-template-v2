// ignore_for_file: avoid_bool_literals_in_conditional_expressions

import 'package:firebase_messaging/firebase_messaging.dart';

/// Helper methods for [RemoteMessage].
abstract final class RemoteMessageHelpers {
  /// Converts a map to [RemoteMessage].
  static RemoteMessage toRemoteMessage(Map<String, dynamic> map) {
    final Object? category = map['category'];
    final Object? collapseKey = map['collapseKey'];
    final Object? contentAvailable = map['contentAvailable'];
    final Object? messageId = map['messageId'];
    final Object? messageType = map['messageType'];
    final Object? ttl = map['ttl'];
    final Object? from = map['from'];
    final Object? mutableContent = map['mutableContent'];
    final Object? senderId = map['senderId'];
    final Object? threadId = map['threadId'];
    return RemoteMessage(
      data: _asMap(map['data']),
      notification: RemoteNotification.fromMap(_asMap(map['notification'])),
      category: category is String ? category : null,
      collapseKey: collapseKey is String ? collapseKey : null,
      contentAvailable: contentAvailable is bool ? contentAvailable : false,
      messageId: messageId is String ? messageId : '',
      messageType: messageType is String ? messageType : '',
      sentTime: DateTime.tryParse(map['sentTime'] as String? ?? ''),
      ttl: ttl is int ? ttl : null,
      from: from is String ? from : null,
      mutableContent: mutableContent is bool ? mutableContent : false,
      senderId: senderId is String ? senderId : null,
      threadId: threadId is String ? threadId : null,
    );
  }

  static Map<String, dynamic> _asMap(Object? d) =>
      d is Map<String, dynamic> ? d : <String, dynamic>{};
}
