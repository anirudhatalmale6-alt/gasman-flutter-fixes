import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'hmrc_widget.dart';
import 'privacy_policy_page.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              TermsContent(),
              PrivacyPolicyScreen()
            ],
          ),
        ),
      ),
    );
  }
}

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  // ================= Launch Functions =================

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@gasmanbusiness.co.uk',
      query: 'subject=Support Request&body=Hello,',
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw Exception('Could not launch email app');
    }
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://www.gasmanbusiness.co.uk');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // ================= UI Helpers =================

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _text(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.5),
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _linkText(String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    ),
  );

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gas Man Business Manager",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // Align(
        //     alignment: AlignmentDirectional.topCenter,
        //     child: Image.asset("assets/ic_what_qr.png",height: 100,width: 100,)),


        HmrcDataHandlingScreen(),

        // 1
        _title("1. Introduction"),
        _text(
            "These Terms & Conditions (“Terms”) govern your use of the Gas Man Business Manager mobile application (“App”, “Service”, “we”, “our”, “us”).\n\n"
                "By using the App, you agree to these Terms. If you do not agree, you must not use the App."),

        // 2
        _title("2. Description of Service"),
        _bullet("Accounting and bookkeeping"),
        _bullet("Invoicing and billing"),
        _bullet("VAT tracking and submission"),
        _bullet("Business and financial management"),
        _bullet("Gas tools"),
        _text(
            "The App may integrate with third-party services such as tax authorities and banking providers."),

        // 3
        _title("3. User Accounts"),
        _bullet("Register an account"),
        _bullet("Provide accurate information"),
        _bullet("Keep your login credentials secure"),
        _text("You are responsible for all activity under your account."),

        // 4
        _title("4. Acceptable Use"),
        _bullet("Use the App for illegal or fraudulent purposes"),
        _bullet("Submit false or misleading financial data"),
        _bullet("Attempt to access other users’ data"),
        _bullet("Interfere with or disrupt the App"),
        _text(
            "We reserve the right to suspend or terminate accounts that violate these rules."),

        // 5
        _title("5. Financial & Tax Responsibility"),
        _text(
            "The App provides tools to assist with accounting, VAT submissions, and gas industry tools.\n\nHowever:"),
        _bullet("You are responsible for the accuracy of your data"),
        _bullet("You are responsible for reviewing all submissions"),
        _bullet("We are not liable for incorrect tax filings"),
        _text("You should seek professional advice where necessary."),

        // 6
        _title("6. VAT Submission & Compliance"),
        _bullet("Authorise the App to submit data on your behalf"),
        _bullet("Confirm the data submitted is accurate"),
        _bullet("Accept responsibility for compliance with tax laws"),

        // 7
        _title("7. Third-Party Services"),
        _bullet("Tax authority systems"),
        _bullet("Open Banking providers"),
        _bullet("Cloud hosting services"),
        _text(
            "We are not responsible for the performance or availability of these services."),

        // 8
        _title("8. Data & Privacy"),
        _text(
            "Your use of the App is also governed by our Privacy Policy.\n\n"
                "We take reasonable steps to protect your data but cannot guarantee absolute security."),

        // 9
        _title("9. Service Availability"),
        _bullet("Uninterrupted service"),
        _bullet("Error-free operation"),
        _text(
            "We may update, modify, or discontinue features at any time."),

        // 10
        _title("10. Limitation of Liability"),
        _bullet("We are not liable for financial losses"),
        _bullet(
            "We are not liable for losses from using gas tools — always verify with official resources such as Gas Safe Handbook, Corgi, Viper books, etc."),
        _bullet("We are not liable for tax penalties or errors"),
        _bullet("We are not liable for data loss or system downtime"),
        _text("Use of the App is at your own risk."),

        // 11
        _title("11. Termination"),
        _bullet("You breach these Terms"),
        _bullet("We are required to by law"),
        _text("You may stop using the App at any time."),

        // 12
        _title("12. Intellectual Property"),
        _text(
            "All content, design, and code within the App are owned by Gas Man Business Manager.\n\n"
                "You may not copy, distribute, or modify any part of the App without permission."),

        // 13
        _title("13. Changes to Terms"),
        _text(
            "We may update these Terms from time to time.\n\n"
                "Continued use of the App means you accept the updated Terms."),

        // 14
        _title("14. Governing Law"),
        _text("These Terms are governed by the laws of England and Wales."),

        // 15 Contact
        _title("15. Contact"),

        _linkText(
          "📧 Email: info@gasmanbusiness.co.uk",
          _launchEmail,
        ),

        const SizedBox(height: 8),

        _linkText(
          "🌐 Website: https://www.gasmanbusiness.co.uk",
          _launchWebsite,
        ),

        const SizedBox(height: 8),

        const Text("🏢 Business Name: Gas Man Business Manager"),
      ],
    );
  }
}