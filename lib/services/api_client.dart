import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../pages/new_tax_and_invoice/api_service/api_config.dart';
import '../pages/new_tax_and_invoice/api_service/auth_token_store.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  static Future<ApiClient> create({
    Function? onError,
  }) async {
    final token = await AuthTokenStore.read();

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = await AuthTokenStore.read();
          if (t != null) {
            options.headers["Authorization"] = "Bearer $t";
          }
          handler.next(options);
        },
        onError: (exception, handler) async {
          final requestOptions = exception.requestOptions;
          int retryCount = requestOptions.extra["retry"] ?? 0;

          bool shouldRetry =
              exception.type == DioExceptionType.connectionTimeout ||
              exception.type == DioExceptionType.receiveTimeout ||
              exception.type == DioExceptionType.sendTimeout ||
              exception.type == DioExceptionType.connectionError ||
              exception.type == DioExceptionType.unknown;

          if (shouldRetry && retryCount < 3) {
            retryCount++;
            requestOptions.extra["retry"] = retryCount;

            debugPrint(
              "RETRY API ${requestOptions.path} "
              "Attempt: $retryCount",
            );

            await Future.delayed(
              Duration(seconds: retryCount * 2),
            );

            try {
              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(exception);
            }
          }

          debugPrint("API ERROR: ${exception.message}");

          if (onError != null) {
            onError();
          }

          handler.next(exception);
        },
      ),
    );

    if (token != null) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }

    return ApiClient._(dio);
  }
}
