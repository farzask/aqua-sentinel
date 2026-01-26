import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/profile_details_container_widget.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.only(top: 8, bottom: 8),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue,
              padding: EdgeInsetsGeometry.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 60,
                      child: Icon(
                        Icons.person_outlined,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nikhil Ashok',
                      style: kWaterFlowTextStyle.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsetsGeometry.all(25),
              child: Container(
                padding: EdgeInsetsGeometry.all(15),
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
                child: Column(
                  children: [
                    ProfileDetailsContainer(
                      icon: Icons.person_outlined,
                      fieldtag: 'Name',
                      fieldValue: 'Nikhil Ashok',
                    ),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    ProfileDetailsContainer(
                      icon: Icons.location_on_outlined,
                      fieldtag: 'Address',
                      fieldValue: '123 Main Street, Peshawar',
                    ),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    ProfileDetailsContainer(
                      icon: Icons.call_outlined,
                      fieldtag: 'Contact Number',
                      fieldValue: '+92 345 6783098',
                    ),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    ProfileDetailsContainer(
                      icon: Icons.mail_outline,
                      fieldtag: 'Email',
                      fieldValue: 'nikhil.ashok@email.com',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
