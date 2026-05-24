import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/main.dart';
import 'package:the_gas_man_app/services/api_client.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import '../pages/new_tax_and_invoice/api_service/api_config.dart';
import '../pages/new_tax_and_invoice/api_service/auth_token_store.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<void> login({
    required String email,
    required String password,
    required String deviceToken,
  }) async {
    try {
      final res = await dio.post("/auth/login", data: {
        "email": email,
        "password": password,
        "deviceToken": deviceToken,
        "deviceType": Platform.isAndroid ? "android" : "ios",
      });

      print("Response Token ${jsonEncode(res.data)}");
      if (res.data['user'] != null) {
        userRole = res.data["user"]['role'];
      }

      final token = res.data["token"] as String?;
      if (token == null || token.isEmpty) {
        throw Exception("No token returned from login.");
      }

      await AuthTokenStore.save(token);
      await AuthTokenStore.saveEmail(email);
    } catch (e) {
      print("❌ Login Exception: $e");

      // If using Dio, print detailed error
      if (e is DioException) {
        print("🔴 Dio Error Message: ${e.message}");
        print("🔴 Status Code: ${e.response?.statusCode}");
        print("🔴 Response Data: ${e.response?.data}");
        ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['error'] ?? "Invalid Login details"),
            backgroundColor: Colors.red,
          ),
        );
      }

      rethrow; // keep throwing so UI can handle it
    }
  }

  Future<void> register(
      {required String email, required String password}) async {
    final res = await dio.post("/auth/register", data: {
      "email": email,
      "password": password,
    });

    final token = res.data["token"] as String?;
    if (token == null || token.isEmpty) {
      throw Exception("No token returned from registration.");
    }

    await AuthTokenStore.save(token);
    await AuthTokenStore.saveEmail(email);
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final res = await dio.post("/auth/forgot-password", data: {
      "email": email,
    });

    final data = res.data;
    debugPrint("Hello ${jsonEncode(data)}");

    if (data["otpSent"] == true) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Failed to send OTP");
    }
  }

  // ============================================================
  // 🔢 STEP 2: VERIFY OTP
  // ============================================================
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await dio.post("/auth/verify-otp", data: {
      "email": email,
      "otp": otp,
    });

    final data = res.data;

    debugPrint("Hello ${jsonEncode(data)}");

    if (data["verified"] == true) {
      return data; // contains resetToken
    } else {
      throw Exception(data["message"] ?? "Invalid OTP");
    }
  }

  // ============================================================
  // 🔑 STEP 3: RESET PASSWORD
  // ============================================================
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final res = await dio.post("/auth/reset-password", data: {
      "email": email,
      "resetToken": resetToken,
      "newPassword": newPassword,
    });

    final data = res.data;

    if (data["success"] == true) {
      return;
    } else {
      throw Exception(data["message"] ?? "Password reset failed");
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await AuthTokenStore.read();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await AuthTokenStore.clear();
    Provider.of<AppModel>(mainKey!.currentContext!, listen: false).isLoggedIn =
        false;
  }

  Future<void> deleteAccount({Function? onSuccess}) async {
    ApiClient _client = await ApiClient.create();
    final res = await _client.dio.delete("/team/delete-account");
    final data = res.data;

    if (data["deleted"] == true) {
      await AuthTokenStore.clear();
      await AuthTokenStore.clearEmail();
      onSuccess!();
      return;
    } else {
      throw Exception(data["message"] ?? "Password reset failed");
    }
  }
}
