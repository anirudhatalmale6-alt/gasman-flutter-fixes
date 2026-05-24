import 'dart:convert';
import 'dart:developer';

import 'api_client.dart';

class JobService {
  Future<List<dynamic>> getJobs({
    String? dateFrom,
    String? dateTo,
  }) async {
    final api = await ApiClient.create();

    final res = await api.dio.get(
      "/jobs",
      queryParameters: {
        if (dateFrom != null) "dateFrom": dateFrom,
        if (dateTo != null) "dateTo": dateTo,
      },
    );

    log("Message ${jsonEncode(res.data)}");

    return res.data["jobs"] ?? [];
  }

  Future<dynamic> getJobInfo({required int jobId}) async {
    final api = await ApiClient.create();

    final res = await api.dio.get(
      "/jobs/$jobId",
    );

    log("Message ${res.data}");

    return res.data["job"];
  }

  Future<List<dynamic>> getTodayJobs() async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/jobs/today");

    log("Todays Jobs ${jsonEncode(res.data)}");

    return res.data["jobs"] ?? [];
  }

  Future<List<dynamic>> getUpcomingJobs() async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/jobs/upcoming");

    return res.data["jobs"] ?? [];
  }

  Future<void> createJob(Map<String, dynamic> data) async {
    final api = await ApiClient.create();

    await api.dio.post("/jobs", data: data);
  }

  Future<void> updateJob(
    int id,
    Map<String, dynamic> data,
  ) async {
    final api = await ApiClient.create();

    await api.dio.put("/jobs/$id", data: data);
  }

  Future<void> deleteJob(int id) async {
    final api = await ApiClient.create();

    await api.dio.delete("/jobs/$id");
  }

  Future<void> rescheduleJob({
    required int id,
    required DateTime startTime,
    DateTime? endTime,
    int? engineerId,
  }) async {
    final api = await ApiClient.create();

    await api.dio.patch(
      "/jobs/$id/reschedule",
      data: {
        "startTime": startTime.toIso8601String(),
        if (endTime != null) "endTime": endTime.toIso8601String(),
        if (engineerId != null) "engineerId": engineerId,
      },
    );
  }

  Future<List<dynamic>> getDispatchLiveBoard() async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/dispatch/live-board");
    log("Engineer Data ${jsonEncode(res.data)}");

    return res.data["board"] ?? [];
  }
}
