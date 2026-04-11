import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aqua_sentinel/notification_service.dart';

class LeakRecord {
  final bool wasLeaking;
  final String timestamp;
  final DateTime date;

  LeakRecord({
    required this.wasLeaking,
    required this.timestamp,
    required this.date,
  });
}

class SensorDataNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class SensorData {
  static final SensorData _instance = SensorData._internal();
  static SensorData get instance => _instance;
  factory SensorData() => _instance;
  SensorData._internal();

  // Sensor values
  double ph = 0;
  double tds = 0;
  double turbidity = 0;
  double flowSensor1 = 0;
  double flowSensor2 = 0;
  bool leakStatus = false;
  String leakTimestamp = '';
  bool pump = false;
  double totalLeaked = 0;
  double totalVolume = 0;
  int potability = 0;
  String status = 'Healthy';

  // Accumulated usage from flowSensor2
  double currentMonthUsage = 0;

  // History of flowSensor2 values for the chart
  final List<double> flowHistory = [];

  // Whether we have received at least one update from Firebase
  bool hasData = false;

  // Cached Gemini insight
  String? geminiMessage;
  String? geminiTip;

  // Incremented on each Firebase update, used to detect new data
  int updateCount = 0;

  // Leak history for past alerts
  final List<LeakRecord> leakHistory = [];

  StreamSubscription<DatabaseEvent>? _subscription;

  // Notifier so widgets can listen for updates
  final SensorDataNotifier notifier = SensorDataNotifier();

  void startListening() {
    if (_subscription != null) return;

    debugPrint('SensorData: Starting Firebase listener...');
    final sensorsRef = FirebaseDatabase.instance.ref('sensors');
    _subscription = sensorsRef.onValue.listen(
      (DatabaseEvent event) {
        debugPrint('SensorData: Received data from Firebase');
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) {
          debugPrint('SensorData: Data is null');
          return;
        }

        debugPrint('SensorData: Raw data = $data');

        ph = (data['ph'] as num?)?.toDouble() ?? 0;
        tds = (data['tds'] as num?)?.toDouble() ?? 0;
        turbidity = (data['turbidity'] as num?)?.toDouble() ?? 0;
        flowSensor1 = (data['flow_sensor_1'] as num?)?.toDouble() ?? 0;
        flowSensor2 = (data['flow_sensor_2'] as num?)?.toDouble() ?? 0;
        final newLeakStatus = data['leak_status'] as bool? ?? false;
        leakTimestamp = data['leak_timestamp']?.toString() ?? '';

        // Record leak change in history and notify
        if (newLeakStatus != leakStatus || !hasData) {
          leakHistory.insert(
            0,
            LeakRecord(
              wasLeaking: newLeakStatus,
              timestamp: leakTimestamp,
              date: DateTime.now(),
            ),
          );

          // Show push notification when leak is detected
          if (newLeakStatus && hasData) {
            notificationService.showLeakNotification();
          }
        }
        leakStatus = newLeakStatus;
        pump = data['pump'] as bool? ?? false;
        totalLeaked = (data['total_leaked'] as num?)?.toDouble() ?? 0;
        totalVolume = (data['total_volume'] as num?)?.toDouble() ?? 0;
        potability = (data['potability'] as num?)?.toInt() ?? 0;
        status = potability == 1 ? 'Healthy' : 'Unsafe';

        // Accumulate flow sensor 2 readings
        currentMonthUsage += flowSensor2;

        // Store for chart history
        flowHistory.add(flowSensor2);

        hasData = true;
        updateCount++;
        debugPrint(
          'SensorData: ph=$ph, tds=$tds, turbidity=$turbidity, status=$status',
        );
        notifier.notify();
      },
      onError: (error) {
        debugPrint('SensorData: Firebase listener error: $error');
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}

final sensorData = SensorData();
