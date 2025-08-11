import 'package:flutter/foundation.dart';
import '../../data/services/local_session_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalSessionService _session;
  bool _loading = false;
  bool _isLoggedIn = false;
  String? _email;

  AuthProvider(this._session);

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;

  Future<void> restore() async {
    _loading = true;
    notifyListeners();
    _isLoggedIn = await _session.isLoggedIn();
    _email = await _session.getEmail();
    _loading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    if (password.length < 6) {
      _loading = false;
      notifyListeners();
      return 'Invalid credentials';
    }
    await _session.setLoggedIn(email);
    _isLoggedIn = true;
    _email = email;
    _loading = false;
    notifyListeners();
    return null;
  }

  Future<String?> signup(String email, String password) async {
    return login(email, password);
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    await _session.clear();
    _isLoggedIn = false;
    _email = null;
    _loading = false;
    notifyListeners();
  }
}
