import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_calender/calender_dashboard_page.dart';
import 'package:the_gas_man_app/pages/termsandcondition/terms_and_condition_page.dart';

import '../../../../services/auth_service.dart';
import '../../invoice_and_tax_main_screen.dart';

class InvoiceRegisterScreen extends StatefulWidget {

  final String? fromScreen;
  const InvoiceRegisterScreen({super.key,this.fromScreen});

  @override
  State<InvoiceRegisterScreen> createState() => _InvoiceRegisterScreenState();
}

class _InvoiceRegisterScreenState extends State<InvoiceRegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _acceptedTerms = false;

  Future<void> _register() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    final confirm = _confirm.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError("All fields are required.");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }

    if (password != confirm) {
      _showError("Passwords do not match.");
      return;
    }

    if (!_acceptedTerms) {
      _showError("Please accept Terms & Conditions");
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.register(email: email, password: password);

      if (!mounted) return;
      if(widget.fromScreen != null && widget.fromScreen == "calender"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CalenderDashboardPage(),
          ),
        );
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const InvoiceAndTaxMainScreen(),
          ),
        );
      }


    } catch (e) {
      if (!mounted) return;
      _showError("Registration failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.black87);

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),

              const Text(
                "Create account",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Register to use your accounting app",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 📧 Email
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // 🔒 Password
              TextField(
                controller: _password,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔒 Confirm Password
              TextField(
                controller: _confirm,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Terms Checkbox + RichText
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() => _acceptedTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: textStyle,
                        children: [
                          const TextSpan(text: "I agree to the "),
                          TextSpan(
                            text: "Terms & Conditions",
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const TermsAndConditionsPage(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const TermsAndConditionsPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🚀 Register Button
              FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                  CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}