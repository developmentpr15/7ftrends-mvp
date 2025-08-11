import 'dart:math';

import '../models/user_profile.dart';

class MockAuthService {
  // In-memory store for users (email, password hash)
  final Map<String, String> _users = {};
  UserProfile? _currentUser;

  Future<UserProfile?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (_users.containsKey(email) && _users[email] == password) {
      _currentUser = UserProfile(
        id: Random().nextInt(1000).toString(),
        email: email,
        displayName: 'Mock User',
      );
      return _currentUser;
    }
    throw Exception('Invalid email or password');
  }

  Future<UserProfile> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) {
      throw Exception('Email already exists');
    }
    _users[email] = password;
    _currentUser = UserProfile(
      id: Random().nextInt(1000).toString(),
      email: email,
      displayName: 'New User',
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  UserProfile? get currentUser => _currentUser;
}
