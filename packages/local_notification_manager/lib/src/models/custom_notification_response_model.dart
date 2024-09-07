import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Details of a Notification Action that was triggered.
class CustomNotificationResponseModel {
  /// Constructs an instance of [CustomNotificationResponseModel]
  const CustomNotificationResponseModel({
    required this.responseType,
    this.id,
    this.actionId,
    this.input,
    this.payload,
  });

  /// Constructs an instance of [CustomNotificationResponseModel]
  ///  from a [NotificationResponse].
  factory CustomNotificationResponseModel.fromNotificationResponse(
    NotificationResponse response,
  ) {
    return CustomNotificationResponseModel(
      responseType:
          CustomNotificationResponseModelType.fromNotificationResponseType(
        response.notificationResponseType,
      ),
      id: response.id,
      actionId: response.actionId,
      input: response.input,
      payload: response.payload,
    );
  }

  /// The notification's id.
  ///
  /// This is nullable as support for this only supported for notifications
  /// created using version 10 or newer of this plugin.
  final int? id;

  /// The id of the action that was triggered.
  final String? actionId;

  /// The value of the input field if the notification action had an input
  /// field.
  final String? input;

  /// The notification's payload.
  final String? payload;

  /// The notification response type.
  final CustomNotificationResponseModelType responseType;
}

/// The possible notification response types
enum CustomNotificationResponseModelType {
  /// Indicates that a user has selected a notification.
  selectedNotification,

  /// Indicates the a user has selected a notification action.
  selectedNotificationAction;

  /// Converts [NotificationResponseType] to [CustomNotificationResponseModelType].
  static CustomNotificationResponseModelType fromNotificationResponseType(
    NotificationResponseType responseType,
  ) {
    switch (responseType) {
      case NotificationResponseType.selectedNotification:
        return CustomNotificationResponseModelType.selectedNotification;
      case NotificationResponseType.selectedNotificationAction:
        return CustomNotificationResponseModelType.selectedNotificationAction;
    }
  }
}

/// Helper extension methods for custom notification response.
extension CustomNotificationResponseModelX on CustomNotificationResponseModel {
  /// Converts [CustomNotificationResponseModel] to [NotificationResponse].
  NotificationResponse get toNotificationResponse => NotificationResponse(
        id: id,
        actionId: actionId,
        input: input,
        payload: payload,
        notificationResponseType: responseType.toNotificationResponseType,
      );
}

/// Helper extension methods for custom notification response type.
extension CustomNotificationResponseModelTypeX
    on CustomNotificationResponseModelType {
  /// Converts [CustomNotificationResponseModelType] to [NotificationResponseType].
  NotificationResponseType get toNotificationResponseType {
    switch (this) {
      case CustomNotificationResponseModelType.selectedNotification:
        return NotificationResponseType.selectedNotification;
      case CustomNotificationResponseModelType.selectedNotificationAction:
        return NotificationResponseType.selectedNotificationAction;
    }
  }
}
