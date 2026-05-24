import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/main.dart';


 String? userRole = "owner";

class Utils {
  static bool _isShowing = false;

  /// Show loading dialog
  static void showLoading({
    String message = "Please wait...",
    bool dismissible = false,
  }) {
    if (_isShowing) return;

    _isShowing = true;

    showDialog(
      context: mainKey!.currentContext!,
      barrierDismissible: dismissible,
      builder: (_) => WillPopScope(
        onWillPop: () async => dismissible,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(mainKey!.currentContext!, rootNavigator: true).pop();
    }
  }

  /// Circular progress widget
  static Widget circular({
    double size = 24,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  /// Linear progress widget
  static Widget linear({
    double height = 4,
    Color? color,
    Color? backgroundColor,
  }) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

Future<dynamic> push(Widget screen) async {
  return await Navigator.push(mainKey!.currentContext!,
      CupertinoPageRoute(builder: (context) {
    return screen;
  }));
}

Future<dynamic> pushRemoveUntill(Widget screen) async {
  return await Navigator.pushAndRemoveUntil(mainKey!.currentContext!,
      CupertinoPageRoute(builder: (context) {
        return screen;
      }),(route) => false,);
}

void showRedSnackbar(String message) {
  ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
     SnackBar(
      content: Text(message),
      backgroundColor: Colors.red, // 🔴 RED
    ),
  );
}

extension StringDecimalExtension on String {
  String toTwoDecimal() {
    final number = double.tryParse(this);
    if (number == null) return this; // or return '0.00' if you prefer
    return number.toStringAsFixed(2);
  }
}
