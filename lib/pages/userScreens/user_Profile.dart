import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/widgets/profile_details_container_widget.dart';
import 'package:aqua_sentinel/sensor_data.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blue,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                        sensorData.userName,
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
                        fieldValue: sensorData.userName,
                      ),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      ProfileDetailsContainer(
                        icon: Icons.location_on_outlined,
                        fieldtag: 'Address',
                        fieldValue: sensorData.address,
                      ),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      ProfileDetailsContainer(
                        icon: Icons.call_outlined,
                        fieldtag: 'Contact Number',
                        fieldValue: sensorData.phoneNumber,
                      ),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      ProfileDetailsContainer(
                        icon: Icons.mail_outline,
                        fieldtag: 'Email',
                        fieldValue: sensorData.email,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
