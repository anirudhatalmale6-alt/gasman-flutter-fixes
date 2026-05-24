import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      sentAt: DateTime.fromMillisecondsSinceEpoch(
        map['sentAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': sentAt.millisecondsSinceEpoch,
    };
  }
}
