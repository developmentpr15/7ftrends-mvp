import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../shared/constants.dart';
import '../../../shared/validation.dart';
import 'auth_screen.dart';
import '../home/home_scaffold.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }
    if (_auth.profile == null) {
      return AuthScreen(auth: _auth);
    }
    return HomeScaffold(auth: _auth);
  }
}
