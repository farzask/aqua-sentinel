// ignore: file_names
import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/past_alert_card_widget.dart';
import 'package:aqua_sentinel/sensor_data.dart';
import 'package:intl/intl.dart';

class UserAlerts extends StatefulWidget {
  const UserAlerts({super.key});

  @override
  State<UserAlerts> createState() => _UserAlertsState();
}

class _UserAlertsState extends State<UserAlerts> {
  @override
  void initState() {
    super.initState();
    sensorData.notifier.addListener(_onUpdate);
  }

  @override
  void dispose() {
    sensorData.notifier.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  String _formatLeakDateTime(LeakRecord record) {
    final date = DateFormat('MMM d, yyyy').format(record.date);
    final time = DateFormat.jm().format(record.date);
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    // Only leakage events in past alerts (skip the first/current entry)
    final pastLeakAlerts = sensorData.leakHistory.length > 1
        ? sensorData.leakHistory
            .sublist(1)
            .where((r) => r.wasLeaking)
            .toList()
        : <LeakRecord>[];

    final String currentTime = sensorData.leakHistory.isNotEmpty
        ? DateFormat.jm().format(sensorData.leakHistory[0].date)
        : DateFormat.jm().format(DateTime.now());

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blue,
        child: ListView(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 22, vertical: 20),
          children: [
            // Current alert
            Container(
              width: double.infinity,
              padding: EdgeInsetsGeometry.only(
                left: 15,
                top: 18,
                bottom: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: sensorData.leakStatus
                        ? Color(0xfff4e4e5)
                        : Color(0xffe4f4e5),
                    radius: 25,
                    child: sensorData.leakStatus
                        ? Icon(Icons.warning_amber, size: 22, color: Colors.red)
                        : Icon(
                            Icons.check_circle,
                            size: 22,
                            color: Colors.green,
                          ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                sensorData.leakStatus
                                    ? 'Leakage Detected'
                                    : 'No Leakage',
                                style: kCardHeadingTextStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy').format(DateTime.now()),
                                  style: kCardHeadingTextStyle.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w100,
                                    letterSpacing: 0.5,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  currentTime,
                                  style: kCardHeadingTextStyle.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w100,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: 200,
                          child: Text(
                            sensorData.leakStatus
                                ? 'Leakage detected in the main water line. Immediate attention required.'
                                : 'System is functioning normally. No actions needed.',
                            style: kCardHeadingTextStyle.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),

            // Past Alerts section
            Container(
              padding: EdgeInsetsGeometry.only(left: 5),
              child: Text(
                'Past Alerts',
                style: kCardHeadingTextStyle.copyWith(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8),

            if (pastLeakAlerts.isEmpty)
              PastAlertContainer(
                cardStatus: 'No past alerts',
                iconName: Icons.check_circle,
                time: '',
              )
            else
              ...pastLeakAlerts.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PastAlertContainer(
                    cardStatus: 'Leakage Detected',
                    iconName: Icons.warning_amber,
                    iconColor: Colors.red,
                    iconBgColor: const Color(0x1AF44336),
                    time: _formatLeakDateTime(record),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
