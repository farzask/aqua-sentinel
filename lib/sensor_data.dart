import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> toJson() => {
    'wasLeaking': wasLeaking,
    'timestamp': timestamp,
    'date': date.toIso8601String(),
  };

  factory LeakRecord.fromJson(Map<String, dynamic> json) => LeakRecord(
    wasLeaking: json['wasLeaking'] as bool,
    timestamp: json['timestamp'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
  );
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

  String userName = 'Farza Shahzad';
  String address = '123 Main Street, Peshawar';
  String phoneNumber = '+92 300 1234567';
  String email = 'abc.123@gmail.com';

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

  // Flow history for the chart (persisted locally)
  final List<double> flowHistory = [];

  // Whether we have received at least one update from Firebase
  bool hasData = false;

  // Cached Gemini insight
  String? geminiMessage;
  String? geminiTip;

  // Incremented on each Firebase update, used to detect new data
  int updateCount = 0;

  // Leak history for past alerts (persisted locally)
  final List<LeakRecord> leakHistory = [];

  StreamSubscription<DatabaseEvent>? _subscription;

  // Notifier so widgets can listen for updates
  final SensorDataNotifier notifier = SensorDataNotifier();

  // ── Local persistence ────────────────────────────────────────────────────

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore leak history
      final leakJson = prefs.getString('leak_history');
      if (leakJson != null) {
        final list = jsonDecode(leakJson) as List<dynamic>;
        leakHistory.addAll(
          list.map((e) => LeakRecord.fromJson(e as Map<String, dynamic>)),
        );
      }

      // Restore flow history (chart data)
      final flowJson = prefs.getString('flow_history');
      if (flowJson != null) {
        final list = jsonDecode(flowJson) as List<dynamic>;
        flowHistory.addAll(list.map((e) => (e as num).toDouble()));
      }

      debugPrint(
        'SensorData: Loaded ${leakHistory.length} leak records and '
        '${flowHistory.length} flow readings from storage',
      );
    } catch (e) {
      debugPrint('SensorData: Failed to load from storage: $e');
    }
  }

  Future<void> _saveLeakHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'leak_history',
        jsonEncode(leakHistory.map((r) => r.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('SensorData: Failed to save leak history: $e');
    }
  }

  Future<void> _saveFlowHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep at most 200 readings to avoid unbounded growth
      final toSave = flowHistory.length > 200
          ? flowHistory.sublist(flowHistory.length - 200)
          : flowHistory;
      await prefs.setString('flow_history', jsonEncode(toSave));
    } catch (e) {
      debugPrint('SensorData: Failed to save flow history: $e');
    }
  }

  // ── Firebase listener ────────────────────────────────────────────────────

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

        // Record leak state change and persist
        if (newLeakStatus != leakStatus || !hasData) {
          leakHistory.insert(
            0,
            LeakRecord(
              wasLeaking: newLeakStatus,
              timestamp: leakTimestamp,
              date: DateTime.now(),
            ),
          );
          _saveLeakHistory();

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

        // Append flow reading for chart history and persist
        flowHistory.add(flowSensor2);
        _saveFlowHistory();

        hasData = true;
        updateCount++;
        debugPrint(
          'SensorData: ph=$ph, tds=$tds, turbidity=$turbidity, '
          'totalVolume=$totalVolume, status=$status',
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
