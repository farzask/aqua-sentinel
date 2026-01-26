import 'package:flutter/material.dart';
import 'package:aqua_sentinel/widgets/reusable_flow_card_widget.dart';
import 'package:aqua_sentinel/widgets/reusable_alert_card_widget.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/reusable_leak_detected_card.dart';

class AdminDashboard extends StatelessWidget {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReusableFlowCard(
              cardTitle: 'Outlet Flow Sensor',
              primaryText: '1200',
              unit: 'L/m',
              cardIcon: Icons.water_drop_outlined,
            ),
            SizedBox(height: 18),
            ReusableFlowCard(
              cardTitle: 'Houses Connect',
              primaryText: '250',
              unit: '',
              cardIcon: Icons.house_outlined,
            ),
            SizedBox(height: 18),
            ReusableAlertCard(
              cardTitle: 'Leakage Detection',
              primaryText: '5.8',
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
    );
  }
}
