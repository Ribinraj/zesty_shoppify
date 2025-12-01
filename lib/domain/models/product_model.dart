// lib/models/product_model.dart
class ProductModel {
  final String id;
  final String title;
  final String handle;
  final String? description;
  final String? imageUrl;
  final String? variantId;
  final String? price;

  ProductModel({
    required this.id,
    required this.title,
    required this.handle,
    this.description,
    this.imageUrl,
    this.variantId,
    this.price,
  });

  /// Build ProductModel from a GraphQL `product` node (products.edges[].node).
  factory ProductModel.fromGraphQL(Map<String, dynamic> node) {
    // Safely extract image URL from node['images']['edges'][0]['node']['url']
    String? imageUrl;
    try {
      final images = node['images']?['edges'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map<String, dynamic>) {
          final imageNode = firstImage['node'] as Map<String, dynamic>?;
          imageUrl = imageNode?['url'] as String?;
        }
      }
    } catch (_) {
      imageUrl = null;
    }

    // Safely extract variant info from node['variants']['edges'][0]['node']
  // Safely extract variant info from node['variants']['edges'][0]['node']
String? variantId;
String? price;
try {
  final variants = node['variants']?['edges'] as List<dynamic>?;
  if (variants != null && variants.isNotEmpty) {
    final firstVariant = variants.first;
    if (firstVariant is Map<String, dynamic>) {
      final variantNode = firstVariant['node'] as Map<String, dynamic>?;
      variantId = variantNode?['id'] as String?;
      // price is MoneyV2 { amount, currencyCode }
      final priceNode = variantNode?['price'] as Map<String, dynamic>?;
      final amount = priceNode?['amount']?.toString();
      final currency = priceNode?['currencyCode']?.toString();
      if (amount != null && currency != null) {
        price = '$amount $currency';
      } else if (amount != null) {
        price = amount;
      } else {
        price = null;
      }
    }
  }
} catch (_) {
  variantId = null;
  price = null;
}


    return ProductModel(
      id: node['id'] as String,
      title: (node['title'] as String?) ?? '',
      handle: (node['handle'] as String?) ?? '',
      description: node['description'] as String?,
      imageUrl: imageUrl,
      variantId: variantId,
      price: price,
    );
  }

  /// Optional: convert model to JSON (useful for caching / debugging)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'handle': handle,
        'description': description,
        'imageUrl': imageUrl,
        'variantId': variantId,
        'price': price,
      };

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, handle: $handle, price: $price, imageUrl: $imageUrl)';
  }
}
