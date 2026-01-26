import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class NavBarItem extends StatelessWidget {
  final String label;
  final IconData iconName;
  final bool isActive;
  final int itemNumber;
  final void Function(int) selectButton;

  NavBarItem({
    required this.label,
    required this.iconName,
    required this.isActive,
    required this.itemNumber,
    required this.selectButton,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectButton(itemNumber);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconName,
              color: isActive ? kActiveItemColor : kInactiveItemColor,
            ),
            Text(
              label,
              style: kCardHeadingTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isActive ? kActiveItemColor : kInactiveItemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
