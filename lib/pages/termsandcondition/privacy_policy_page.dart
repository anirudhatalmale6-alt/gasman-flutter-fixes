import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _text(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        // 🔙 Custom Top Bar
        Row(
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),

        const Divider(height: 10),
        const SizedBox(
          height: 5.0,
        ),

        // 📄 Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _text("Privacy Policy for Gas Man Business Manager"),
            _text("Effective Date: 01/04/2026"),
            _title("1. Introduction"),
            _text(
                "Welcome to Gas Man Business Manager (“we”, “our”, “us”). We are committed to protecting your privacy and handling your data in an open and transparent manner."),
            _text(
                "This Privacy Policy explains how we collect, use, store, and protect your information when you use our mobile application."),
            _title("2. Information We Collect"),
            _text("We may collect and process the following data:"),
            _text("a) Personal Information"),
            _bullet("Name"),
            _bullet("Email address"),
            _bullet("Phone number"),
            _bullet("Business details (company name, VAT number, address)"),
            _text("b) Financial & Business Data"),
            _bullet("Invoices and billing information"),
            _bullet("Supplier and customer details"),
            _bullet("Bank account details (if connected via Open Banking)"),
            _bullet("VAT records and tax data"),
            _text("c) Technical Data"),
            _bullet("Device type"),
            _bullet("IP address"),
            _bullet("App usage data"),
            _bullet("Log data"),
            _title("3. How We Use Your Information"),
            _text("We use your data to:"),
            _bullet("Provide and operate the app"),
            _bullet("Manage your accounts, invoices, and records"),
            _bullet("Submit VAT returns to HMRC (if authorised)"),
            _bullet("Improve app performance and features"),
            _bullet("Communicate with you regarding updates or support"),
            _title("4. Legal Basis for Processing (UK GDPR)"),
            _text("We process your data under:"),
            _bullet("Contractual necessity (to provide services)"),
            _bullet("Legal obligation (tax compliance)"),
            _bullet("Legitimate interests (improving our services)"),
            _bullet("Consent (for optional features like bank connections)"),
            _title("5. Sharing Your Information"),
            _text("We do not sell your data."),
            _text("We may share data with:"),
            _bullet("HMRC for VAT submissions"),
            _bullet("Open Banking providers (e.g. TrueLayer)"),
            _bullet("Cloud hosting providers (secure data storage)"),
            _bullet("Legal authorities if required by law"),
            _title("6. Data Storage & Security"),
            _text("We implement appropriate security measures including:"),
            _bullet("Encryption (HTTPS)"),
            _bullet("Secure authentication (JWT tokens)"),
            _bullet("Access controls"),
            _text(
                "Your data is stored securely on cloud servers and protected against unauthorised access."),
            _title("7. Data Retention"),
            _text("We retain your data only as long as necessary:"),
            _bullet("Accounting records: up to 7 years (UK legal requirement)"),
            _bullet("User account data: until account deletion"),
            _title("8. Your Rights"),
            _text("Under UK GDPR, you have the right to:"),
            _bullet("Access your data"),
            _bullet("Correct inaccurate data"),
            _bullet("Request deletion"),
            _bullet("Restrict processing"),
            _bullet("Data portability"),
            _text(
                "To exercise these rights, contact us at:\n📧 info@gasmanbusiness.co.uk"),
            _title("9. Third-Party Services"),
            _text(
                "Our app may integrate with third-party services, including:"),
            _bullet("HMRC"),
            _bullet("Open Banking providers"),
            _text("These providers have their own privacy policies."),
            _title("10. Children’s Privacy"),
            _text(
                "Our app is not intended for users under 18. We do not knowingly collect data from children."),
            _title("11. Changes to This Policy"),
            _text(
                "We may update this Privacy Policy from time to time. Changes will be posted within the app or on our website."),
            _title("12. Contact Us"),
            _text("If you have any questions, contact us at:"),
            _text("📧 Contact us: 020 3951 5020"),
            _text("📧 Email: info@gasmanbusiness.co.uk"),
            _text("🏢 Business Name: Gas Man Business Manager"),
            const Text(
              "Effective Date: 01/04/2026",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }
}
