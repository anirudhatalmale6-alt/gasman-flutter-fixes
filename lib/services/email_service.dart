import 'api_client.dart';

class EmailService {
  Future<void> sendInvoiceEmail({
    required int invoiceId,
    String? toEmail,
    String? subject,
    String? body,
  }) async {
    final api = await ApiClient.create();
    await api.dio.post(
      "/email/invoices/$invoiceId/send",
      data: {
        if (toEmail != null && toEmail.trim().isNotEmpty) "toEmail": toEmail.trim(),
        if (subject != null && subject.trim().isNotEmpty) "subject": subject.trim(),
        if (body != null && body.trim().isNotEmpty) "body": body.trim(),
      },
    );
  }

  Future<void> sendBillEmail({
    required int billId,
    String? toEmail,
    String? subject,
    String? body,
  }) async {
    final api = await ApiClient.create();
    await api.dio.post(
      "/email/bills/$billId/send",
      data: {
        if (toEmail != null && toEmail.trim().isNotEmpty) "toEmail": toEmail.trim(),
        if (subject != null && subject.trim().isNotEmpty) "subject": subject.trim(),
        if (body != null && body.trim().isNotEmpty) "body": body.trim(),
      },
    );
  }

  Future<void> sendVatSummaryEmail({
    required String toEmail,
    required String dateFrom,
    required String dateTo,
  }) async {
    final api = await ApiClient.create();

    await api.dio.post(
      "/email/vat-summary/send",
      data: {
        "toEmail": toEmail.trim(),
        "dateFrom": dateFrom, // format: yyyy-MM-dd
        "dateTo": dateTo,
      },
    );
  }

}
