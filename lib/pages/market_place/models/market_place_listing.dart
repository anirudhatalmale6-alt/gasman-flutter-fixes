import 'package:flutter/foundation.dart';

enum ListingCondition { newItem, used, refurbished }
enum DeliveryOption { postage, collection, both }

@immutable
class MarketplaceListing {
  final String id;
  final String title;
  final String partNumber;
  final String barcode;
  final String description;
  final double price;
  final double? shippingPrice;
  final bool paypalEnabled;
  final ListingCondition condition;
  final DeliveryOption deliveryOption;
  final String category;
  final String sellerId;
  final String sellerName;
  final String locationPostcode;
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool isActive;
  final bool approved;

  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.partNumber,
    required this.barcode,
    required this.description,
    required this.price,
    this.shippingPrice,
    required this.paypalEnabled,
    required this.condition,
    required this.deliveryOption,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.locationPostcode,
    required this.imageUrls,
    required this.createdAt,
    required this.isActive,
    required this.approved,
  });

  MarketplaceListing copyWith({
    String? id,
    String? title,
    String? partNumber,
    String? barcode,
    String? description,
    double? price,
    double? shippingPrice,
    bool? paypalEnabled,
    ListingCondition? condition,
    DeliveryOption? deliveryOption,
    String? category,
    String? sellerId,
    String? sellerName,
    String? locationPostcode,
    List<String>? imageUrls,
    DateTime? createdAt,
    bool? isActive,
    bool? approved,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      title: title ?? this.title,
      partNumber: partNumber ?? this.partNumber,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      price: price ?? this.price,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      paypalEnabled: paypalEnabled ?? this.paypalEnabled,
      condition: condition ?? this.condition,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      category: category ?? this.category,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      locationPostcode: locationPostcode ?? this.locationPostcode,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      approved: approved ?? this.approved,
    );
  }

  factory MarketplaceListing.fromMap(String id, Map<String, dynamic> map) {
    return MarketplaceListing(
      id: id,
      title: map['title'] ?? '',
      partNumber: map['partNumber'] ?? '',
      barcode: map['barcode'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      shippingPrice: map['shippingPrice'] != null
          ? (map['shippingPrice']).toDouble()
          : null,
      paypalEnabled: map['paypalEnabled'] ?? false,
      condition: ListingCondition.values[map['condition'] ?? 0],
      deliveryOption: DeliveryOption.values[map['deliveryOption'] ?? 0],
      category: map['category'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      locationPostcode: map['locationPostcode'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? const []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isActive: map['isActive'] ?? true,
      approved: map['approved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'partNumber': partNumber,
      'barcode': barcode,
      'description': description,
      'price': price,
      'shippingPrice': shippingPrice,
      'paypalEnabled': paypalEnabled,
      'condition': condition.index,
      'deliveryOption': deliveryOption.index,
      'category': category,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'locationPostcode': locationPostcode,
      'imageUrls': imageUrls,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'approved': approved,
    };
  }
}
