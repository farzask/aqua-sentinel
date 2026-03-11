import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';

class ProfileDetailsContainer extends StatelessWidget {
  final IconData icon;
  final String fieldtag;
  final String fieldValue;
  const ProfileDetailsContainer({
    super.key,
    required this.icon,
    required this.fieldtag,
    required this.fieldValue,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.only(bottom: 6, top: 3),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            radius: 22,
            child: Icon(icon, color: Colors.blue, size: 25),
          ),
          SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldtag,
                style: kCardHeadingTextStyle.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                width: 220,
                child: Text(
                  fieldValue,
                  style: kCardHeadingTextStyle.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
