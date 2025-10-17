import 'package:aqua_sentinel/utils/theme.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return BaseTheme(
      column: Column(
        children: [
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAdmin = true),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      title: 'Admin Dashboard',
    );
  }
}
