import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;

  Future<void> _reset() async {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.resetPassword(
        email: widget.email,
        newPassword: _password.text,
        resetToken: widget.resetToken,
      );

      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock, size: 72),
              const SizedBox(height: 20),

              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _loading ? null : _reset,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}