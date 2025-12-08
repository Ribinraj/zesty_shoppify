

class ProductFilter {
  final String? productType;
  final String? vendor;
  final List<String>? tags;
  final PriceRange? price;
  final bool? available;
  final List<String>? variantOptions;

  ProductFilter({
    this.productType,
    this.vendor,
    this.tags,
    this.price,
    this.available,
    this.variantOptions,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (productType != null) map['productType'] = productType;
    if (vendor != null) map['vendor'] = vendor;
    if (tags != null && tags!.isNotEmpty) map['tag'] = tags;
    if (price != null) {
      map['price'] = {
        'min': price!.min,
        'max': price!.max,
      };
    }
    if (available != null) map['available'] = available;
    if (variantOptions != null) map['variantOption'] = variantOptions;
    return map;
  }
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({required this.min, required this.max});
}

enum ProductSortKey {
  title('TITLE'),
  price('PRICE'),
  bestSelling('BEST_SELLING'),
  created('CREATED'),
  relevance('RELEVANCE');

  final String value;
  const ProductSortKey(this.value);
}
// lib/domain/models/collection_model.dart
class CollectionModel {
  final String id;
  final String title;
  final String handle;
  final String? description;
  final String? imageUrl;
  final int productsCount;

  CollectionModel({
    required this.id,
    required this.title,
    required this.handle,
    this.description,
    this.imageUrl,
    this.productsCount = 0,
  });

  factory CollectionModel.fromGraphQL(Map<String, dynamic> node) {
    String? imageUrl;
    try {
      final image = node['image'] as Map<String, dynamic>?;
      imageUrl = image?['url'] as String?;
    } catch (_) {
      imageUrl = null;
    }

    // Parse productsCount from the products.edges array length
    int productsCount = 0;
    try {
      final productsData = node['products'] as Map<String, dynamic>?;
      if (productsData != null) {
        final edges = productsData['edges'] as List<dynamic>?;
        productsCount = edges?.length ?? 0;
      }
    } catch (e) {
      // Fallback: try the old format (productsCount field)
      try {
        final oldFormat = node['productsCount'] as Map<String, dynamic>?;
        if (oldFormat != null) {
          final edges = oldFormat['edges'] as List<dynamic>?;
          productsCount = edges?.length ?? 0;
        }
      } catch (_) {
        productsCount = 0;
      }
    }

    return CollectionModel(
      id: node['id'] as String,
      title: (node['title'] as String?) ?? '',
      handle: (node['handle'] as String?) ?? '',
      description: node['description'] as String?,
      imageUrl: imageUrl,
      productsCount: productsCount,
    );
  }
}