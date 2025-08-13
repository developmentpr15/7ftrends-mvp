import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;

  bool get isLoggedIn => _profile != null;
  bool get isLoading => _isLoading;
  UserProfile? get profile => _profile;

  static const _userKey = 'user_profile';

  AuthProvider() {
    loadSession();
  }

  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();
    
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
        _profile = UserProfile(
          userId: userId,
          email: email,
          username: username,
          displayName: displayName,
          bio: bio ?? '',
          avatarUrl: avatarUrl ?? '',
          createdAt: createdAt,
        );
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
      final username = email.split('@')[0];
      _profile = UserProfile(
        userId: DateTime.now().toString(),
        email: email,
        username: username,
        displayName: username,
        bio: 'Fashion enthusiast',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: DateTime.now(),
      );
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
      _profile = UserProfile(
        userId: DateTime.now().toString(),
        email: email,
        username: username,
        displayName: username,
        bio: 'Fashion enthusiast',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: DateTime.now(),
      );
      await _saveProfile(_profile!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _saveProfile(updated);
      _profile = updated;
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

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_userKey}_id', profile.userId);
    await prefs.setString('${_userKey}_username', profile.username);
    await prefs.setString('${_userKey}_display_name', profile.displayName);
    await prefs.setString('${_userKey}_email', profile.email);
    await prefs.setString('${_userKey}_bio', profile.bio);
    await prefs.setString('${_userKey}_avatar_url', profile.avatarUrl);
    await prefs.setInt('${_userKey}_created_at', profile.createdAt.millisecondsSinceEpoch);
  }
}
