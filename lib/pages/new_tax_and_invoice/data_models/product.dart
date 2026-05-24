class Product {
  final int id;
  final String name;
  final String sku;
  final String type; // service or inventory
  final double price;
  final double cost;
  final int? quantityOnHand;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.type,
    required this.price,
    required this.cost,
    this.quantityOnHand,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      id: j['id'],
      name: j['name'],
      sku: j['sku'],
      type: j['type'],
      price: (j['price'] as num).toDouble(),
      cost: (j['cost'] as num).toDouble(),
      quantityOnHand: j['quantityOnHand'],
    );
  }
}
