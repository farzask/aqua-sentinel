import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

/// Call once from main() to configure and auto-start the background service.
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Create a low-priority channel for the persistent "monitoring" notification.
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'aqua_sentinel_bg',
          'Aqua Sentinel Background',
          description: 'Keeps the leak monitor running in the background',
          importance: Importance.low,
        ),
      );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'aqua_sentinel_bg',
      initialNotificationTitle: 'Aqua Sentinel',
      initialNotificationContent: 'Monitoring water system...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: _onStart,
      onBackground: _onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}

/// Runs in an **isolated** background Dart isolate.
/// Keeps its own Firebase connection and fires local notifications when a
/// leak is detected — even if the main app UI has been swiped away.
@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Firebase must be initialised separately in every isolate.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up local-notifications in this isolate.
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'leak_alerts',
          'Leak Alerts',
          description: 'Notifications for water leak detection',
          importance: Importance.max,
        ),
      );

  bool lastLeakStatus = false;
  bool hasFirstUpdate = false;

  // Listen to the full sensors node so we can include totalLeaked in the
  // notification body.
  FirebaseDatabase.instance.ref('sensors').onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;

    final newLeakStatus = data['leak_status'] as bool? ?? false;

    // Show a notification only when status flips false → true.
    if (hasFirstUpdate && newLeakStatus && !lastLeakStatus) {
      final now = DateTime.now();
      plugin.show(
        0, // same ID used by the in-app notification — avoids duplicates
        'Leakage Detected!',
        'A water leak detected at '
            '${DateFormat('MMM d, yyyy').format(now)}, '
            '${DateFormat('h:mm a').format(now)}. '
            'Immediate attention required.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'leak_alerts',
            'Leak Alerts',
            channelDescription: 'Notifications for water leak detection',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }

    lastLeakStatus = newLeakStatus;
    hasFirstUpdate = true;
  });

  // Let the main app stop the service if needed.
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}
