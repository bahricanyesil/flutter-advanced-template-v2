/// Enum representing various types of permissions.
enum PermissionTypes {
  /// Permission for accessing the device's calendar.
  calendar,

  /// Permission for accessing the device's camera.
  camera,

  /// Permission for accessing the device's contacts.
  contacts,

  /// Permission for accessing the device's location.
  location,

  /// Permission for accessing the device's location always.
  locationAlways,

  /// Permission for accessing the device's location when the app is in use.
  locationWhenInUse,

  /// Permission for accessing the device's media library.
  mediaLibrary,

  /// Permission for accessing the device's microphone.
  microphone,

  /// Permission for accessing the device's phone state.
  phone,

  /// Permission for accessing the device's photos.
  photos,

  /// Permission for adding photos to the device's photo library.
  photosAddOnly,

  /// Permission for accessing the device's reminders.
  reminders,

  /// Permission for accessing the device's sensors.
  sensors,

  /// Permission for sending and reading SMS messages.
  sms,

  /// Permission for accessing speech recognition.
  speech,

  /// Permission for accessing external storage.
  storage,

  /// Permission for ignoring battery optimizations.
  ignoreBatteryOptimizations,

  /// Permission for pushing notifications.
  notification,

  /// Permission for accessing the device's media location.
  accessMediaLocation,

  /// Permission for accessing activity recognition.
  activityRecognition,

  /// Permission for accessing Bluetooth.
  bluetooth,

  /// Permission for managing external storage.
  manageExternalStorage,

  /// Permission for creating system alert windows.
  systemAlertWindow,

  /// Permission for requesting to install packages.
  requestInstallPackages,

  /// Permission for app tracking transparency.
  appTrackingTransparency,

  /// Permission for sending critical alerts.
  criticalAlerts,

  /// Permission for accessing notification policy.
  accessNotificationPolicy,

  /// Permission for scanning Bluetooth devices.
  bluetoothScan,

  /// Permission for advertising Bluetooth devices.
  bluetoothAdvertise,

  /// Permission for connecting to Bluetooth devices.
  bluetoothConnect,

  /// Permission for accessing nearby Wi-Fi devices.
  nearbyWifiDevices,

  /// Permission for accessing the device's video files.
  videos,

  /// Permission for accessing the device's audio files.
  audio,

  /// Permission for scheduling exact alarms.
  scheduleExactAlarm,

  /// Permission for accessing sensors in the background.
  sensorsAlways,

  /// Permission for writing to the device's calendar.
  calendarWriteOnly,

  /// Permission for reading from and writing to the device's calendar.
  calendarFullAccess,

  /// Permission for accessing device's assistant capabilities.
  assistant,

  /// Permission for reading the current background refresh status.
  backgroundRefresh,

  /// Permission for accessing unknown permissions.
  unknown,
}
