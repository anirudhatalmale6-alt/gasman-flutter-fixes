import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  NetworkService._();

  static final NetworkService instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isDialogShowing = false;

  /// START LISTENING
  void start(BuildContext context) {
    _subscription?.cancel();

    _subscription = _connectivity.onConnectivityChanged.listen(
          (results) {
        final hasConnection = !results.contains(
          ConnectivityResult.none,
        );

        if (!hasConnection) {
          _showDisconnectedDialog(context);
        } else {
          _hideDisconnectedDialog(context);
         // _showConnectedSnackBar(context);
        }
      },
    );
  }

  /// DISCONNECTED DIALOG
  void _showDisconnectedDialog(BuildContext context) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 8),
              Text("No Internet"),
            ],
          ),
          content: const Text(
            "Please check your internet connection.",
          ),
        );
      },
    );
  }

  /// HIDE DIALOG
  void _hideDisconnectedDialog(BuildContext context) {
    if (!_isDialogShowing) return;

    _isDialogShowing = false;

    Navigator.of(context, rootNavigator: true).pop();
  }

  /// CONNECTED MESSAGE
  void _showConnectedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Internet Connected"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// DISPOSE
  void dispose() {
    _subscription?.cancel();
  }
}