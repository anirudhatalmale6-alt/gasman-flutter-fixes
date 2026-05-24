import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool loading = false;

  Future<void> sendResetEmail() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );

      Navigator.pop(context); // go back to login
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Something went wrong")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Enter your email and we’ll send you a reset link",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: sendResetEmail,
              child: const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
