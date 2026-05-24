import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/pages/new_calender/calender_dashboard_page.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/auth/invoice_forgot_password_screen.dart';
import 'package:the_gas_man_app/pages/settings/engineer_settings_page.dart';
import 'package:the_gas_man_app/services/company_service.dart';
import 'package:the_gas_man_app/utils_class/notification_utils.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../main.dart';
import '../../../../services/auth_service.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../../../new_invoice_page/data_model/all_models.dart';
import '../../invoice_and_tax_main_screen.dart';
import '../invite_user/accept_invite_screen.dart';
import 'invoice_register_screen.dart';

class InvoiceLoginScreen extends StatefulWidget {
  final String? fromScreen;

  const InvoiceLoginScreen({super.key, this.fromScreen});

  @override
  State<InvoiceLoginScreen> createState() => _InvoiceLoginScreenState();
}

class _InvoiceLoginScreenState extends State<InvoiceLoginScreen> {
  final _email = TextEditingController();
  final AccountStorage _storage = AccountStorage();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscure = false;

  var _companyService = CompanyService();
  File? _logoFile;

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await NotificationUtils.getFCmToken();
      await _auth.login(email: email, password: password, deviceToken: token!);
      await getCompanyDetailsAndStore();
      if (!mounted) return;
      if (widget.fromScreen != null && widget.fromScreen == "company") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const CompanyInformationPage(shouldShowAppBar: true)),
        );
      } else if (widget.fromScreen != null && widget.fromScreen == "calender") {
        if (RolePermissions.canAccessJobs(userRole!)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CalenderDashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
            SnackBar(
              content: Text("You can't access Job Management System "),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (RolePermissions.canAccessAccounting(userRole!)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceAndTaxMainScreen()),
          );
        } else {
          ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
            SnackBar(
              content: Text("You can't access Account and tax system "),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      Provider.of<AppModel>(context, listen: false).isLoggedIn = true;
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.account_balance_wallet, size: 72),
              const SizedBox(height: 20),
              const Text(
                "Welcome back",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to your accounting system",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                child: const Text("Forgot password?"),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Login"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvoiceRegisterScreen(
                              fromScreen: widget.fromScreen,
                            ),
                          ),
                        );
                      },
                child: const Text("Create an account"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AcceptInviteScreen(),
                          ),
                        );
                      },
                child: const Text(
                  "Have an invitation code? Join your team",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCompanyDetailsAndStore() async {
    try {
      final data = await _companyService.getCompany();
      if (data["logo_url"] != null && data["logo_url"].toString().isNotEmpty) {
        String _logoUrl = "https://api.gasmanbusiness.co.uk${data["logo_url"]}";
        _logoFile = await _companyService.urlToFile(_logoUrl!);
      }
      await _save(data);
    } catch (e) {
      if (mounted) {
        setState(() {});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _save(Map<String, dynamic> data) async {
    _storage.settings = AccountingSettings(
      businessName: data["business_name"] ?? "",
      businessAddress: data["address"] ?? "",
      engineerName: data["name"] ?? "",
      businessEmail: data["email"] ?? "",
      businessPhone: data["phone"] ?? "",
      vatRegistered: data["vrn"] != null && data["vrn"].toString().isNotEmpty,
      vatNumber: data["vrn"] ?? "",
      invoicePrefix: data["invoice_prefix"] ?? "INV",
      nextInvoiceNumber: _storage.settings.nextInvoiceNumber,
      nextApiInvoiceNumber: _storage.settings.nextApiInvoiceNumber,
      nextEstimateNumber: _storage.settings.nextEstimateNumber,
      nextApiBillNumber: _storage.settings.nextApiBillNumber,
      logoPath: _logoFile != null ? _logoFile?.path : "",
      gasSafeNumber: data["gas_safe_number"] ?? "",
      postalCode: data["postal_code"] ?? "",
      paymentDetails: data["payment_details"] ?? "",
    );
    await _storage.saveSettings();
  }
}
