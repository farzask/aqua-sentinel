import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class ReusableFlowCard extends StatelessWidget {
  final String cardTitle;
  final String primaryText;
  final String unit;
  final IconData cardIcon;

  const ReusableFlowCard({
    super.key,
    required this.cardTitle,
    required this.primaryText,
    required this.unit,
    required this.cardIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12, horizontal: 18),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cardTitle, style: kCardHeadingTextStyle),
              Icon(cardIcon, color: Colors.blue),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(primaryText, style: kWaterFlowTextStyle),
              SizedBox(width: 5),
              Text(unit, style: kCardHeadingTextStyle.copyWith(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
