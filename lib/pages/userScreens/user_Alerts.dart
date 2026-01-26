import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/past_alert_card_widget.dart';

class UserAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsetsGeometry.only(
                left: 15,
                top: 18,
                bottom: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xfff4e4e5),
                    radius: 25,
                    child: Icon(
                      Icons.warning_amber,
                      size: 22,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                'Leakage Detected',
                                style: kCardHeadingTextStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              'Today, 10:30 AM',
                              style: kCardHeadingTextStyle.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w100,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: 200,
                          child: Text(
                            'Leakage detected in the main water line. Immediate attention required.',
                            style: kCardHeadingTextStyle.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsetsGeometry.only(left: 5),
                  child: Text(
                    'Past Alerts',
                    style: kCardHeadingTextStyle.copyWith(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                PastAlertContainer(
                  cardStatus: 'Everything Normal',
                  iconName: Icons.check_circle,
                  time: 'Yesterday, 2:15 PM',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
