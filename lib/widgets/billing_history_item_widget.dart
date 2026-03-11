import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class BillingHistoryItem extends StatelessWidget {
  final String bill;
  final String date;
  const BillingHistoryItem({super.key, required this.bill, required this.date});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\$ $bill",
              style: kCardHeadingTextStyle.copyWith(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 2),
            Text(
              date,
              style: kCardHeadingTextStyle.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
