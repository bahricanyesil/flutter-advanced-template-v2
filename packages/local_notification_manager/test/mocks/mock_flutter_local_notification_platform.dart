// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final class MockFlutterLocalNotificationPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterLocalNotificationsPlatform {}
