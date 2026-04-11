import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aqua_sentinel/widgets/reusable_flow_card_widget.dart';
import 'package:aqua_sentinel/widgets/reusable_alert_card_widget.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/reusable_leak_detected_card.dart';
import 'package:aqua_sentinel/sensor_data.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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

  void _togglePump(bool value) {
    FirebaseDatabase.instance.ref('sensors/pump').set(value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.only(
          top: 35,
          left: 25,
          right: 25,
          bottom: 10,
        ),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pump control toggle
            Container(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 14,
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water,
                        color: sensorData.pump ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Water Pump',
                        style: kWaterFlowTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: sensorData.pump,
                    activeColor: Colors.blue,
                    onChanged: _togglePump,
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            ReusableFlowCard(
              cardTitle: 'Outlet Flow Sensor',
              primaryText: sensorData.flowSensor1.toStringAsFixed(2),
              unit: 'L/m',
              cardIcon: Icons.water_drop_outlined,
            ),
            SizedBox(height: 18),
            ReusableFlowCard(
              cardTitle: 'Houses Connect',
              primaryText: '1',
              unit: '',
              cardIcon: Icons.house_outlined,
            ),
            SizedBox(height: 18),
            ReusableAlertCard(
              cardTitle: 'Leakage Detection',
              primaryText: sensorData.totalLeaked.toString(),
              unit: 'L',
              cardIcon: Icons.warning_amber,
            ),
            SizedBox(height: 25),
            //Alert Container
            Container(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 12,
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts',
                    style: kWaterFlowTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  ReusableLeakDetectedCard(),
                  SizedBox(height: 18),
                  ReusableLeakDetectedCard(),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
