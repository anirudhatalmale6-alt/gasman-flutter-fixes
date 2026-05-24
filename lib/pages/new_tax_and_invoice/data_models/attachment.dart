

class Attachment {
  final int id;
  final int parentId;
  final String fileName;
  final String fileUrl;
  final String fileType;

  Attachment({
    required this.id,
    required this.parentId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      parentId: json['parentId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
    );
  }
}
