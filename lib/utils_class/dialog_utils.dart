import 'package:flutter/material.dart';

class DialogUtils {
  /// Confirm + Async Action Dialog (with loading)
  static Future<bool> showActionDialog({
    required BuildContext context,
    String title = "Confirm",
    String message = "Are you sure?",
    String confirmText = "Yes",
    String cancelText = "Cancel",
    Color? confirmColor,
    required Future<void> Function() onConfirm, // 👈 your API call
  }) async {
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // prevent closing while loading
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Text(cancelText),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmColor,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() => isLoading = true);
                    try {
                      await onConfirm(); // 👈 API call
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                        ),
                      );
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(confirmText),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  /// Delete Dialog (pre-configured)
  static Future<bool> showDeleteDialog({
    required BuildContext context,
    String itemName = "item",
    required Future<void> Function() onDelete,
  }) async {
    return await showActionDialog(
      context: context,
      title: "Delete",
      message:
      'Are you sure you want to delete "$itemName"?\n\nThis action cannot be undone.',
      confirmText: "Delete",
      confirmColor: Colors.red,
      onConfirm: onDelete,
    );
  }
}