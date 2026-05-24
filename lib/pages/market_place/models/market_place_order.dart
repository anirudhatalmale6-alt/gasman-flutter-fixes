import 'package:flutter/foundation.dart';

enum OrderStatus { pendingPayment, paid, cancelled }

@immutable
class MarketplaceOrder {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final OrderStatus status;
  final String paypalOrderId;
  final DateTime createdAt;
  final DateTime? paidAt;

  const MarketplaceOrder({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
    required this.paypalOrderId,
    required this.createdAt,
    this.paidAt,
  });

  factory MarketplaceOrder.fromMap(String id, Map<String, dynamic> map) {
    return MarketplaceOrder(
      id: id,
      listingId: map['listingId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: OrderStatus.values[map['status'] ?? 0],
      paypalOrderId: map['paypalOrderId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      paidAt: map['paidAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paidAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'amount': amount,
      'status': status.index,
      'paypalOrderId': paypalOrderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'paidAt': paidAt?.millisecondsSinceEpoch,
    };
  }
}

