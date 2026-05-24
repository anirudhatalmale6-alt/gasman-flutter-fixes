import 'package:flutter/material.dart';

class HmrcDataHandlingScreen extends StatelessWidget {
  const HmrcDataHandlingScreen({super.key});

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        sectionTitle("HMRC Data Handling"),

        paragraph(
          "Our application connects to HM Revenue and Customs (HMRC) systems via their Making Tax Digital (MTD) API to submit VAT returns and retrieve tax obligations on your behalf.",
        ),

        sectionTitle("What HMRC data we access and store:"),

        bulletPoint(
          "VAT obligations (due dates, periods, submission status)",
        ),

        bulletPoint(
          "VAT return data (boxes 1-9 as calculated from your invoices and bills)",
        ),

        bulletPoint(
          "HMRC connection tokens (encrypted, used to authenticate with HMRC on your behalf)",
        ),

        paragraph(
          "We do NOT store your Government Gateway login credentials. Authentication is handled securely via HMRC's OAuth 2.0 process - you log in directly with HMRC and grant our application permission.",
        ),

        sectionTitle("How long we keep HMRC data:"),

        bulletPoint(
          "VAT return submissions are retained for 7 years to comply with HMRC record-keeping requirements",
        ),

        bulletPoint(
          "HMRC authentication tokens are stored only while your HMRC connection is active and are deleted immediately when you disconnect",
        ),

        sectionTitle("Who can access your HMRC data:"),

        bulletPoint(
          "Only you (the account holder) and any team members you have added to your account",
        ),

        bulletPoint(
          "Our system administrators for technical support purposes only",
        ),

        bulletPoint(
          "No HMRC data is shared with any third parties",
        ),

        sectionTitle("Security measures:"),

        bulletPoint(
          "All data is transmitted over encrypted HTTPS (TLS 1.2/1.3) connections",
        ),

        bulletPoint(
          "HMRC tokens are stored in an encrypted database",
        ),

        bulletPoint(
          "Access requires authenticated login with JWT-based session tokens",
        ),

        bulletPoint(
          "The server is hosted in a secure data centre with restricted access",
        ),

        sectionTitle("Your rights:"),

        bulletPoint(
          "You can disconnect from HMRC at any time via the app settings, which removes all stored HMRC tokens",
        ),

        bulletPoint(
          "You can request deletion of your HMRC submission history by contacting us",
        ),

        bulletPoint(
          "You can request a copy of your HMRC-related data",
        ),

        const SizedBox(height: 30),

        const Divider(),

        sectionTitle("HMRC Integration"),

        paragraph(
          "By connecting your HMRC account through our application, you authorise us to:",
        ),

        bulletPoint(
          "Retrieve your VAT obligations and return data from HMRC",
        ),

        bulletPoint(
          "Submit VAT returns to HMRC on your behalf",
        ),

        paragraph(
          "You are responsible for ensuring the accuracy of all VAT data before submission. Once a VAT return is submitted to HMRC, it cannot be reversed through our application.",
        ),

        paragraph(
          "You can revoke HMRC access at any time by disconnecting your HMRC account in the app settings.",
        ),

        paragraph(
          "We comply with HMRC's fraud prevention requirements and transmit device and connection information as required by HMRC's Making Tax Digital regulations.",
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}