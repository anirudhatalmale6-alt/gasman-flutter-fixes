
/*import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class AttachmentService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<Map<String, dynamic>> upload({
    required String parentType, // "invoice" | "bill"
    required int parentId,
    required File file,
  }) async {
    final token = await AuthTokenStore.read();

    final form = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });

    final res = await _dio.post(
      "/$parentType/$parentId/attachments",
      data: form,
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );

    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> list({
    required String parentType,
    required int parentId,
  }) async {
    final token = await AuthTokenStore.read();
    final res = await _dio.get(
      "/$parentType/$parentId/attachments",
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    return (res.data["attachments"] as List);
  }

  Future<void> deleteAttachment(int attachmentId) async {
    final token = await AuthTokenStore.read();
    await _dio.delete(
      "/attachments/$attachmentId",
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
  }
}*/
