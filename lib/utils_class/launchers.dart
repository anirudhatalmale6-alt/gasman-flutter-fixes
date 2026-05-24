import 'package:url_launcher/url_launcher.dart';

class Launchers {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open URL");
    }
  }

  static Future<void> email({
    required String to,
    String subject = "",
    String body = "",
  }) async {
    final uri = Uri(
      scheme: "mailto",
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) "subject": subject,
        if (body.isNotEmpty) "body": body,
      },
    );

    if (!await launchUrl(uri)) {
      throw Exception("Could not open email client");
    }
  }

  static Future<void> call(String phoneNumber) async {
    final uri = Uri(scheme: "tel", path: phoneNumber);
    if (!await launchUrl(uri)) {
      throw Exception("Could not open dialer");
    }
  }
}

