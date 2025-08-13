import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  final Map<String, dynamic> initial;
  final Set<String> takenUsernames;

  const ProfileEditScreen({
    super.key,
    required this.initial,
    required this.takenUsernames,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Text('Edit Profile Screen'),
      ),
    );
  }
}
