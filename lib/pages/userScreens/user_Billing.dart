import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/billing_history_item_widget.dart';

class UserBilling extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
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
                    "\$ 125.50",
                    style: kWaterFlowTextStyle.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Prediction for Next Month \$ 130.00',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meter Status',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        'Active',
                        style: kCardHeadingTextStyle.copyWith(
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Billing History',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsetsGeometry.all(5),
                      children: [
                        BillingHistoryItem(
                          bill: '110.00',
                          date: 'January 2024',
                        ),
                        SizedBox(height: 8),
                        BillingHistoryItem(
                          bill: '105.00',
                          date: 'December 2023',
                        ),
                        SizedBox(height: 8),
                        BillingHistoryItem(
                          bill: '95.00',
                          date: 'November 2023',
                        ),
                      ],
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
