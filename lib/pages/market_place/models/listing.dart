class Listing {
  final String id;
  final String title;
  final double price;
  final String postcode;
  final List<String> imageUrls;

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.postcode,
    required this.imageUrls,
  });

  // From JSON
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      postcode: json['postcode'] ?? '',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'postcode': postcode,
      'imageUrls': imageUrls,
    };
  }
}
