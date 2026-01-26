import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/utils/circular_progress_bar.dart';
import 'package:aqua_sentinel/utils/line_chart.dart';

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 22, vertical: 20),
        children: [
          Container(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'This Month\'s Usage',
                      style: kCardHeadingTextStyle.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CircularProgressDisplay(
                  value: 0.50, // For 75% completion
                  label: '1200L',
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You\'ve used 85% of your monthly goal.',
                      style: kCardHeadingTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 15),
                  Text(
                    'Past Months Usage',
                    style: kWaterFlowTextStyle.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsetsGeometry.only(
                  top: 20,
                  left: 18,
                  right: 18,
                  bottom: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Usage',
                          style: kCardHeadingTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Last 9 Months',
                          style: kCardHeadingTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '7500 L',
                          style: kWaterFlowTextStyle.copyWith(fontSize: 21),
                        ),
                      ],
                    ),
                    WaterUsageChart(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
