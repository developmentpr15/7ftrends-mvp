import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
	const AuthScreen({super.key});

	@override
	State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
	final _formKey = GlobalKey<FormState>();
	String _email = '';
	String _password = '';
	bool _isLoading = false;

	void _login() {
		if (_formKey.currentState!.validate()) {
			setState(() => _isLoading = true);
			// Simulate login delay
			Future.delayed(const Duration(seconds: 2), () {
				setState(() => _isLoading = false);
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Logged in!')),
				);
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Sign In')),
			body: Center(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(24),
					child: Form(
						key: _formKey,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								TextFormField(
									decoration: const InputDecoration(labelText: 'Email'),
									keyboardType: TextInputType.emailAddress,
									validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
									onChanged: (value) => _email = value,
								),
								const SizedBox(height: 16),
								TextFormField(
									decoration: const InputDecoration(labelText: 'Password'),
									obscureText: true,
									validator: (value) => value != null && value.length >= 6 ? null : 'Password too short',
									onChanged: (value) => _password = value,
								),
								const SizedBox(height: 24),
								_isLoading
										? const CircularProgressIndicator()
										: ElevatedButton(
												onPressed: _login,
												child: const Text('Login'),
											),
							],
						),
					),
				),
			),
		);
	}
}
