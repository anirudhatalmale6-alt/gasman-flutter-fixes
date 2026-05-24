import 'package:flutter/foundation.dart';

@immutable
class ChatConversation {
  final String id;
  final String listingId;
  final String listingTitle;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final DateTime updatedAt;
  final String lastMessagePreview;

  const ChatConversation({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.updatedAt,
    required this.lastMessagePreview,
  });

  factory ChatConversation.fromMap(String id, Map<String, dynamic> map) {
    return ChatConversation(
      id: id,
      listingId: map['listingId'] ?? '',
      listingTitle: map['listingTitle'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastMessagePreview: map['lastMessagePreview'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastMessagePreview': lastMessagePreview,
    };
  }
}
