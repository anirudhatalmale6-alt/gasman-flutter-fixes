import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/login_page.dart';
import '../market_place_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final phoneNumber = TextEditingController();

  final MarketplaceService _marketplaceService = MarketplaceService.instance;

  bool loading = false;

  void register() async {
    setState(() => loading = true);

    await _marketplaceService.registerUser(
      email: email.text.trim(),
      password: password.text.trim(),
      name: name.text.trim(),
      address: address.text.trim(),
      phone: phoneNumber.text.trim(),
      onSuccess: () {
        setState(() => loading = false);
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return LoginPage();
        }));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );

        Navigator.pop(context); // go back to login
      },
      onFailed: () {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneNumber,
              decoration: const InputDecoration(hintText: "Phone"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: address,
              decoration: const InputDecoration(hintText: "Address"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: password,
              decoration: const InputDecoration(hintText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: const Text("Create Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
