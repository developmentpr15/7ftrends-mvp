import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double radius;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Use new AvatarCircle signature
    return CircleAvatar(
      radius: radius,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
