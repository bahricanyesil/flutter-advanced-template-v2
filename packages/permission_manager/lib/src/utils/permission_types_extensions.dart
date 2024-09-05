import 'package:permission_handler/permission_handler.dart';

import '../enums/permission_types.dart';

/// Extension to convert `PermissionTypes` to `Permission`.
extension PermissionTypesExtensions on PermissionTypes {
  /// Converts `PermissionTypes` to `Permission`.
  Permission get toPermission {
    switch (this) {
      case PermissionTypes.calendar:
        return Permission.calendarFullAccess;
      case PermissionTypes.camera:
        return Permission.camera;
      case PermissionTypes.contacts:
        return Permission.contacts;
      case PermissionTypes.location:
        return Permission.location;
      case PermissionTypes.locationAlways:
        return Permission.locationAlways;
      case PermissionTypes.locationWhenInUse:
        return Permission.locationWhenInUse;
      case PermissionTypes.mediaLibrary:
        return Permission.mediaLibrary;
      case PermissionTypes.microphone:
        return Permission.microphone;
      case PermissionTypes.phone:
        return Permission.phone;
      case PermissionTypes.photos:
        return Permission.photos;
      case PermissionTypes.photosAddOnly:
        return Permission.photosAddOnly;
      case PermissionTypes.reminders:
        return Permission.reminders;
      case PermissionTypes.sensors:
        return Permission.sensors;
      case PermissionTypes.sms:
        return Permission.sms;
      case PermissionTypes.speech:
        return Permission.speech;
      case PermissionTypes.storage:
        return Permission.storage;
      case PermissionTypes.ignoreBatteryOptimizations:
        return Permission.ignoreBatteryOptimizations;
      case PermissionTypes.notification:
        return Permission.notification;
      case PermissionTypes.accessMediaLocation:
        return Permission.accessMediaLocation;
      case PermissionTypes.activityRecognition:
        return Permission.activityRecognition;
      case PermissionTypes.bluetooth:
        return Permission.bluetooth;
      case PermissionTypes.manageExternalStorage:
        return Permission.manageExternalStorage;
      case PermissionTypes.systemAlertWindow:
        return Permission.systemAlertWindow;
      case PermissionTypes.requestInstallPackages:
        return Permission.requestInstallPackages;
      case PermissionTypes.appTrackingTransparency:
        return Permission.appTrackingTransparency;
      case PermissionTypes.criticalAlerts:
        return Permission.criticalAlerts;
      case PermissionTypes.accessNotificationPolicy:
        return Permission.accessNotificationPolicy;
      case PermissionTypes.bluetoothScan:
        return Permission.bluetoothScan;
      case PermissionTypes.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case PermissionTypes.bluetoothConnect:
        return Permission.bluetoothConnect;
      case PermissionTypes.nearbyWifiDevices:
        return Permission.nearbyWifiDevices;
      case PermissionTypes.videos:
        return Permission.videos;
      case PermissionTypes.audio:
        return Permission.audio;
      case PermissionTypes.scheduleExactAlarm:
        return Permission.scheduleExactAlarm;
      case PermissionTypes.sensorsAlways:
        return Permission.sensorsAlways;
      case PermissionTypes.calendarWriteOnly:
        return Permission.calendarWriteOnly;
      case PermissionTypes.calendarFullAccess:
        return Permission.calendarFullAccess;
      case PermissionTypes.assistant:
        return Permission.assistant;
      case PermissionTypes.backgroundRefresh:
        return Permission.backgroundRefresh;
      default:
        return Permission.unknown;
    }
  }
}

/// Extension to convert `Permission` to `PermissionTypes`.
extension PermissionExtension on Permission {
  /// Converts `Permission` to `PermissionTypes`.
  PermissionTypes get toPermissionType {
    switch (this) {
      case Permission.calendarFullAccess:
        return PermissionTypes.calendar;
      case Permission.camera:
        return PermissionTypes.camera;
      case Permission.contacts:
        return PermissionTypes.contacts;
      case Permission.location:
        return PermissionTypes.location;
      case Permission.locationAlways:
        return PermissionTypes.locationAlways;
      case Permission.locationWhenInUse:
        return PermissionTypes.locationWhenInUse;
      case Permission.mediaLibrary:
        return PermissionTypes.mediaLibrary;
      case Permission.microphone:
        return PermissionTypes.microphone;
      case Permission.phone:
        return PermissionTypes.phone;
      case Permission.photos:
        return PermissionTypes.photos;
      case Permission.photosAddOnly:
        return PermissionTypes.photosAddOnly;
      case Permission.reminders:
        return PermissionTypes.reminders;
      case Permission.sensors:
        return PermissionTypes.sensors;
      case Permission.sms:
        return PermissionTypes.sms;
      case Permission.speech:
        return PermissionTypes.speech;
      case Permission.storage:
        return PermissionTypes.storage;
      case Permission.ignoreBatteryOptimizations:
        return PermissionTypes.ignoreBatteryOptimizations;
      case Permission.notification:
        return PermissionTypes.notification;
      case Permission.accessMediaLocation:
        return PermissionTypes.accessMediaLocation;
      case Permission.activityRecognition:
        return PermissionTypes.activityRecognition;
      case Permission.bluetooth:
        return PermissionTypes.bluetooth;
      case Permission.manageExternalStorage:
        return PermissionTypes.manageExternalStorage;
      case Permission.systemAlertWindow:
        return PermissionTypes.systemAlertWindow;
      case Permission.requestInstallPackages:
        return PermissionTypes.requestInstallPackages;
      case Permission.appTrackingTransparency:
        return PermissionTypes.appTrackingTransparency;
      case Permission.criticalAlerts:
        return PermissionTypes.criticalAlerts;
      case Permission.accessNotificationPolicy:
        return PermissionTypes.accessNotificationPolicy;
      case Permission.bluetoothScan:
        return PermissionTypes.bluetoothScan;
      case Permission.bluetoothAdvertise:
        return PermissionTypes.bluetoothAdvertise;
      case Permission.bluetoothConnect:
        return PermissionTypes.bluetoothConnect;
      case Permission.nearbyWifiDevices:
        return PermissionTypes.nearbyWifiDevices;
      case Permission.videos:
        return PermissionTypes.videos;
      case Permission.audio:
        return PermissionTypes.audio;
      case Permission.scheduleExactAlarm:
        return PermissionTypes.scheduleExactAlarm;
      case Permission.sensorsAlways:
        return PermissionTypes.sensorsAlways;
      case Permission.calendarWriteOnly:
        return PermissionTypes.calendarWriteOnly;
      case Permission.calendarFullAccess:
        return PermissionTypes.calendarFullAccess;
      case Permission.assistant:
        return PermissionTypes.assistant;
      case Permission.backgroundRefresh:
        return PermissionTypes.backgroundRefresh;
      default:
        return PermissionTypes.unknown;
    }
  }
}
