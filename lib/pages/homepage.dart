import 'package:aqua_sentinel/utils/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:aqua_sentinel/pages/admin_dashboard.dart';
import 'package:aqua_sentinel/pages/userScreens/user_dashboard.dart';
import 'package:aqua_sentinel/pages/userScreens/user_Billing.dart';
import 'package:aqua_sentinel/pages/userScreens/user_Alerts.dart';
import 'package:aqua_sentinel/pages/userScreens/user_Profile.dart';

bool isAdmin = false;

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;
  List<Widget> userScreens = [
    UserDashboard(),
    UserBilling(),
    UserAlerts(),
    UserProfile(),
  ];

  Widget renderUI() {
    if (isAdmin) {
      return AdminDashboard();
    } else {
      return userScreens[selectedIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7f9),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f7f9),
        title: Text(
          isAdmin ? 'Admin Dashboard' : 'User Dashboard',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF06245E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //Dashboard Slider
          Center(
            child: Container(
              width: 300,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  // Sliding background
                  AnimatedAlign(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isAdmin
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // Text Row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAdmin = false),
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "User",
                                style: TextStyle(
                                  color: isAdmin ? Colors.grey : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAdmin = true),
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "Admin",
                                style: TextStyle(
                                  color: isAdmin ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //Screen Rendering Function
          renderUI(),
        ],
      ),
      bottomNavigationBar: !isAdmin
          ? BottomNavBar(
              selectedIndex: selectedIndex,
              selectButton: (selectedButtonIndex) {
                setState(() {
                  selectedIndex = selectedButtonIndex;
                });
              },
            )
          : null,
    );
  }
}
