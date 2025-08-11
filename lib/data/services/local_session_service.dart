import 'package:shared_preferences/shared_preferences.dart';

class LocalSessionService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kEmail = 'email';

  Future<void> setLoggedIn(String email) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kIsLoggedIn, true);
    await sp.setString(_kEmail, email);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kIsLoggedIn);
    await sp.remove(_kEmail);
  }

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kIsLoggedIn) ?? false;
  }

  Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }
}
