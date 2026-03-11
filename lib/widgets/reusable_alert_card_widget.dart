import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class ReusableAlertCard extends StatelessWidget {
  final String cardTitle;
  final String primaryText;
  final String unit;
  final IconData cardIcon;

  const ReusableAlertCard({
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
        color: Color(0xfff4e4e5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Color(0xfff34043),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardTitle,
                style: kCardHeadingTextStyle.copyWith(color: Color(0xfff34043)),
              ),
              Icon(cardIcon, color: Color(0xfff34043)),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                primaryText,
                style: kWaterFlowTextStyle.copyWith(color: Color(0xfff34043)),
              ),
              SizedBox(width: 5),
              Text(
                unit,
                style: kCardHeadingTextStyle.copyWith(
                  fontSize: 18,
                  color: Color(0xfff34043),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
