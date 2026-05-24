import 'package:flutter/material.dart';

class MarketPlaceTermsConditionsScreen extends StatelessWidget {
  const MarketPlaceTermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: TermsContent(),
      ),
    );
  }
}

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text("Last Updated: 01-04-2026"),

          _title("1. Introduction"),
          _text(
              "Welcome to this marketplace app (“the App”). By accessing or using the App, you agree to be bound by these Terms and Conditions. If you do not agree, you must not use the App."),

          _title("2. Nature of the Service"),
          _text(
              "The App is a peer-to-peer platform that connects buyers and sellers. We do not own, sell, buy, or control any of the items listed. We are not a party to any transaction between users."),

          _title("3. User Responsibility"),
          _text("Users are solely responsible for:"),
          _bullet("The accuracy and legality of their listings"),
          _bullet("The items they buy or sell"),
          _bullet("All communications and interactions with other users"),
          _bullet(
              "Ensuring compliance with all applicable laws and regulations"),
          _text("You use the App at your own risk."),

          _title("4. Prohibited Items and Activities"),
          _text("Users must not list, sell, or promote:"),
          _bullet("Illegal, stolen, or counterfeit goods"),
          _bullet(
              "Dangerous or regulated items where prohibited by law"),
          _bullet(
              "Any goods or services that violate applicable laws or regulations"),
          _text(
              "We reserve the right to remove any listing or suspend accounts that violate these rules."),

          _title("5. No Verification"),
          _text(
              "We do not verify users, listings, or items. We make no guarantees regarding:"),
          _bullet("The quality, safety, or legality of items"),
          _bullet("The accuracy of listings"),
          _bullet(
              "The ability of buyers or sellers to complete transactions"),

          _title("6. Transactions"),
          _text("All transactions are conducted directly between users. We:"),
          _bullet("Do not handle payments"),
          _bullet("Do not offer delivery services"),
          _bullet("Do not guarantee transaction outcomes"),
          _text(
              "Any disputes must be resolved directly between the parties involved."),

          _title("7. Limitation of Liability"),
          _text(
              "To the fullest extent permitted by law, we accept no liability for:"),
          _bullet("Any loss, damage, or financial loss"),
          _bullet("Fraud, scams, or misrepresentation"),
          _bullet("Injury or harm resulting from items purchased"),
          _bullet("Disputes between users"),
          _text("Use of the App is entirely at your own risk."),

          _title("8. Account Suspension and Removal"),
          _text("We reserve the right to:"),
          _bullet("Remove listings without notice"),
          _bullet("Suspend or terminate user accounts"),
          _bullet("Restrict access to the App"),
          _text(
              "This may occur if we believe a user has violated these Terms or applicable laws."),

          _title("9. Content"),
          _text(
              "Users are responsible for any content they upload. By posting content, you grant us the right to display and use it within the App."),

          _title("10. Changes to Terms"),
          _text(
              "We may update these Terms at any time. Continued use of the App after changes means you accept the updated Terms."),

          _title("11. Governing Law"),
          _text(
              "These Terms shall be governed by and interpreted in accordance with the laws of [Your Country]."),

          _title("12. Contact"),
          _text(
              "If you have any questions about these Terms, please contact us at:\n[Insert Contact Email]"),

          const SizedBox(height: 20),

          const Text(
            "By using this App, you agree to these Terms and Conditions.",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}