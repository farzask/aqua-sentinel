import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class PastAlertContainer extends StatelessWidget {
  final String cardStatus;
  final IconData iconName;
  final String time;
  const PastAlertContainer({
    super.key,
    required this.cardStatus,
    required this.iconName,
    required this.time,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsGeometry.symmetric(vertical: 18, horizontal: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            radius: 25,
            child: Icon(iconName, size: 24, color: Colors.green),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    cardStatus,
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.grey[800],
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: kCardHeadingTextStyle.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
