import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  void setUser(UserProfile user) {
    _userProfile = user;
    notifyListeners();
  }

  void clearUser() {
    _userProfile = null;
    notifyListeners();
  }
}
