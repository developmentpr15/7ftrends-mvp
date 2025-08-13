import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for handling authentication state and user profile management
class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  bool get isLoggedIn => _profile != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;

  static const _userKey = 'user_profile';

  AuthProvider() {
    loadSession();
  }

  Future<void> loadSession() async {
    _isLoading = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('${_userKey}_id');
      final username = prefs.getString('${_userKey}_username');
      final displayName = prefs.getString('${_userKey}_display_name');
      final email = prefs.getString('${_userKey}_email');
      final bio = prefs.getString('${_userKey}_bio');
      final avatarUrl = prefs.getString('${_userKey}_avatar_url');
      final createdAt = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('${_userKey}_created_at') ?? DateTime.now().millisecondsSinceEpoch,
      );

      if (userId != null && username != null && displayName != null && email != null) {
        _profile = {
          'userId': userId,
          'email': email,
          'username': username,
          'displayName': displayName,
          'bio': bio ?? '',
          'avatarUrl': avatarUrl ?? '',
          'createdAt': createdAt.toIso8601String(),
        };
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, just create a mock profile
      final username = email.split('@')[0];
      _profile = {
        'userId': DateTime.now().toString(),
        'email': email,
        'username': username,
        'displayName': username,
        'bio': 'Fashion enthusiast',
        'avatarUrl': 'https://example.com/avatar.png',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveProfile(_profile!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, just create a mock profile
      _profile = {
        'userId': DateTime.now().toString(),
        'email': email,
        'username': username,
        'displayName': username, // Using username as displayName by default
        'bio': 'Fashion enthusiast',
        'avatarUrl': 'https://example.com/avatar.png',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveProfile(_profile!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = updated;
      await _saveProfile(_profile!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_userKey}_id');
      await prefs.remove('${_userKey}_username');
      await prefs.remove('${_userKey}_display_name');
      await prefs.remove('${_userKey}_email');
      await prefs.remove('${_userKey}_bio');
      await prefs.remove('${_userKey}_avatar_url');
      await prefs.remove('${_userKey}_created_at');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_userKey}_id', profile['userId']);
    await prefs.setString('${_userKey}_email', profile['email']);
    await prefs.setString('${_userKey}_username', profile['username']);
    await prefs.setString('${_userKey}_display_name', profile['displayName']);
    await prefs.setString('${_userKey}_bio', profile['bio'] ?? '');
    await prefs.setString('${_userKey}_avatar_url', profile['avatarUrl'] ?? '');
    await prefs.setInt('${_userKey}_created_at', DateTime.parse(profile['createdAt']).millisecondsSinceEpoch);
  }
}