class CatalogProduct {
  final int id;
  final String name;
  final String? imageUrl;
  final int stock;
  final double dailyPrice;
  final String? description;
  final String? safety;
  final String status;
  final bool isAvailable;

  const CatalogProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.stock,
    required this.dailyPrice,
    this.description,
    this.safety,
    required this.status,
    required this.isAvailable,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) => CatalogProduct(
        id:          json['id'] as int,
        name:        json['name'] as String,
        imageUrl:    json['imageUrl'] as String?,
        stock:       json['stock'] as int,
        dailyPrice:  (json['dailyPrice'] as num).toDouble(),
        description: json['description'] as String?,
        safety:      json['safety'] as String?,
        status:      json['status'] as String? ?? 'disponible',
        isAvailable: json['isAvailable'] as bool? ?? true,
      );

  /// Converts to the map format expected by ProductDetailScreen.
  Map<String, dynamic> toDetailMap() {
    final priceStr = dailyPrice == dailyPrice.truncateToDouble()
        ? '${dailyPrice.toInt()}€'
        : '${dailyPrice.toStringAsFixed(2)}€';
    return {
      'id':          id,
      'name':        name,
      'price':       priceStr,
      'image':       imageUrl ?? '',
      'description': description ?? '',
      'stock':       stock,
    };
  }
}
