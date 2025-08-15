import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  AuthProvider(this._prefs);

  Future<Map<String, dynamic>> postToApi(String endpoint, Map<String, dynamic> body) async {
    // TODO: Implement API call logic
    return {};
  }
}
