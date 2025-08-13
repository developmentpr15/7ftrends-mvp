import 'package:flutter/material.dart';

import '../../../presentation/providers/auth_provider.dart';
import '../../../shared/constants.dart';
import '../../../shared/validation.dart';

class AuthScreen extends StatefulWidget {
  final AuthProvider auth;
  const AuthScreen({super.key, required this.auth});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _mode = AuthMode.login;
  String _email = '';
  String _password = '';
  String _username = '';
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      if (_mode == AuthMode.login) {
        await widget.auth.login(_email.trim(), _password);
      } else {
        await widget.auth.signup(_email.trim(), _password, _username.trim());
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.auth.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == AuthMode.login ? 'Sign In' : 'Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                  onChanged: (v) => _email = v,
                ),
                const SizedBox(height: 16),
                if (_mode == AuthMode.signup)
                  Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Username'),
                        enabled: !isLoading,
                        validator: (v) => validateUsername(v),
                        onChanged: (v) => _username = v,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  enabled: !isLoading,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                  onChanged: (v) => _password = v,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_mode == AuthMode.login ? 'Login' : 'Sign Up'),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _mode = _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
                          });
                        },
                  child: Text(_mode == AuthMode.login
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
