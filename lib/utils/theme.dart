import 'package:flutter/material.dart';

class BaseTheme extends StatelessWidget {
  final Column column;
  final String title;

  const BaseTheme({super.key, required this.column, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7f9),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f7f9),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF06245E),
          ),
        ),
        centerTitle: true,
      ),
      body: column,
    );
  }
}
