
import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _sendOtp() async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter email")));
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.forgotPassword(email: email);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: email),
        ),
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
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_reset, size: 72),
              const SizedBox(height: 20),
              const Text("Forgot Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Send OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}