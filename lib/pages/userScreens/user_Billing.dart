import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/sensor_data.dart';

class UserBilling extends StatefulWidget {
  const UserBilling({super.key});

  @override
  State<UserBilling> createState() => _UserBillingState();
}

class _UserBillingState extends State<UserBilling> {
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
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double usage = sensorData.flowSensor2;
    final double bill = usage * 20;

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blue,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 30,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Bill',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'PKR ${bill.toStringAsFixed(2)}',
                    style: kWaterFlowTextStyle.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Usage: ${usage.toStringAsFixed(2)} L × Rs 20/L',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Billing History',
              style: kCardHeadingTextStyle.copyWith(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Billing History',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your past bills will appear here.',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
