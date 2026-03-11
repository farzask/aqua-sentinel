import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class ReusableLeakDetectedCard extends StatelessWidget {
  const ReusableLeakDetectedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Color(0xfff4e4e5),
          radius: 22,
          child: Icon(Icons.warning_amber, size: 20, color: Colors.red),
        ),
        SizedBox(width: 8),
        Text(
          'Leakage Detected',
          style: kWaterFlowTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
