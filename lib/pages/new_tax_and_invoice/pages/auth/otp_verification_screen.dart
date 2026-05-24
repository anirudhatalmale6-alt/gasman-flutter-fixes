import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otp = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _verifyOtp() async {
    final otp = _otp.text.trim();

    if (otp.isEmpty) return;

    setState(() => _loading = true);

    try {
     Map<String,dynamic> responseData =  await _auth.verifyOtp(email: widget.email, otp: otp);

     if(responseData['resetToken'] != null){
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => ResetPasswordScreen(
             email: widget.email,
             resetToken: responseData['resetToken'],
           ),
         ),
       );
     }else{
       ScaffoldMessenger.of(context)
           .showSnackBar(SnackBar(content: Text("Failed to verify otp")));
     }

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.security, size: 72),
              const SizedBox(height: 20),
              Text("Enter OTP sent to ${widget.email}",
                  textAlign: TextAlign.center),

              const SizedBox(height: 24),

              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Verify"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}