import 'package:flutter/material.dart';

/// A message meant for the user as-is (no "Exception:" prefix).
class PdfActionMessage implements Exception {
  final String message;

  const PdfActionMessage(this.message);

  @override
  String toString() => message;
}

/// Runs a PDF print/share/email action and shows any failure on screen.
///
/// Before this, an error inside these buttons was swallowed by Flutter and
/// the button looked like it did nothing.
class PdfAction {
  static Future<void> run(
      BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      final text = e is PdfActionMessage
          ? e.message
          : 'Could not create the PDF: ${e.toString().replaceFirst('Exception: ', '')}';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text), duration: const Duration(seconds: 6)),
        );
      }
    }
  }

  static const missingFields = PdfActionMessage(
      'Please fill in the required fields (shown in red) first.');
}
