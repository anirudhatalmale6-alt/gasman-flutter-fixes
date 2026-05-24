import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/browse_items_page.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_home_page.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_service.dart';

import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool isPasswordVisible = false;

  final MarketplaceService _marketplaceService = MarketplaceService.instance;

  void login() async {
    setState(() => loading = true);

    await _marketplaceService.loginUser(
      email: email.text.trim(),
      password: password.text.trim(),
      onFailed: () {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed")),
        );
      },
      onSuccess: () {
        setState(() => loading = false);
       Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context){
         return MarketplaceHomePage();
       }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: password,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                child: const Text("Forgot password?"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                  );
                },
              ),
            ),

            // Loader or Login Button
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),

            TextButton(
              child: const Text("Create Account"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
