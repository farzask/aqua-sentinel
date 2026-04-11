import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(android: androidSettings);

      final result = await _plugin.initialize(initSettings);
      _initialized = result ?? false;

      if (_initialized) {
        // Request notification permission on Android 13+
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      }

      debugPrint('NotificationService: initialized=$_initialized');
    } catch (e) {
      debugPrint('NotificationService: init failed: $e');
      _initialized = false;
    }
  }

  Future<void> showLeakNotification() async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'leak_alerts',
      'Leak Alerts',
      channelDescription: 'Notifications for water leak detection',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      'Leakage Detected!',
      'A water leak has been detected in the main water line. Immediate attention required.',
      details,
    );
  }
}

final notificationService = NotificationService();
