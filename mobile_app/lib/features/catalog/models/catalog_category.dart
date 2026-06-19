import 'catalog_product.dart';

class CatalogCategory {
  final int id;
  final String name;
  final String slug;
  final int order;
  final List<CatalogProduct> products;

  const CatalogCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.order,
    required this.products,
  });

  factory CatalogCategory.fromJson(Map<String, dynamic> json) => CatalogCategory(
        id:       json['id'] as int,
        name:     json['name'] as String,
        slug:     json['slug'] as String,
        order:    json['order'] as int? ?? 0,
        products: (json['products'] as List<dynamic>)
            .map((p) => CatalogProduct.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
