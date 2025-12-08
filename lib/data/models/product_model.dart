
class ProductModel {
  final String id;
  final String title;
  final String handle;
  final String? description;
  final String? imageUrl;
  final String? variantId;
  final String? price;
  final String? compareAtPrice;
  final String? vendor;
  final String? productType;
  final List<String> tags;
  final bool availableForSale;
  final String? minPrice;
  final String? maxPrice;
  final String currencyCode;

  ProductModel({
    required this.id,
    required this.title,
    required this.handle,
    this.description,
    this.imageUrl,
    this.variantId,
    this.price,
    this.compareAtPrice,
    this.vendor,
    this.productType,
    this.tags = const [],
    this.availableForSale = true,
    this.minPrice,
    this.maxPrice,
    this.currencyCode = 'INR',
  });

  bool get isOnSale => compareAtPrice != null && compareAtPrice!.isNotEmpty;

  String? get discountPercentage {
    if (!isOnSale) return null;
    try {
      final regular = double.parse(compareAtPrice!.split(' ').first);
      final sale = double.parse(price!.split(' ').first);
      final discount = ((regular - sale) / regular * 100).round();
      return '$discount%';
    } catch (_) {
      return null;
    }
  }

  factory ProductModel.fromGraphQL(Map<String, dynamic> node) {
    // Extract image URL
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

    // Extract variant info
    String? variantId;
    String? price;
    String? compareAtPrice;
    String currencyCode = 'INR';
    
    try {
      final variants = node['variants']?['edges'] as List<dynamic>?;
      if (variants != null && variants.isNotEmpty) {
        final firstVariant = variants.first;
        if (firstVariant is Map<String, dynamic>) {
          final variantNode = firstVariant['node'] as Map<String, dynamic>?;
          variantId = variantNode?['id'] as String?;
          
          // Price
          final priceNode = variantNode?['price'] as Map<String, dynamic>?;
          final amount = priceNode?['amount']?.toString();
          currencyCode = priceNode?['currencyCode']?.toString() ?? 'INR';
          if (amount != null) {
            price = amount;
          }
          
          // Compare at price
          final compareNode = variantNode?['compareAtPrice'] as Map<String, dynamic>?;
          final compareAmount = compareNode?['amount']?.toString();
          if (compareAmount != null) {
            compareAtPrice = compareAmount;
          }
        }
      }
    } catch (_) {
      variantId = null;
      price = null;
    }

    // Extract price range if available
    String? minPrice;
    String? maxPrice;
    try {
      final priceRange = node['priceRange'] as Map<String, dynamic>?;
      if (priceRange != null) {
        final minVariant = priceRange['minVariantPrice'] as Map<String, dynamic>?;
        final maxVariant = priceRange['maxVariantPrice'] as Map<String, dynamic>?;
        minPrice = minVariant?['amount']?.toString();
        maxPrice = maxVariant?['amount']?.toString();
        currencyCode = minVariant?['currencyCode']?.toString() ?? currencyCode;
      }
    } catch (_) {}

    // Extract tags
    List<String> tags = [];
    try {
      final tagsList = node['tags'] as List<dynamic>?;
      if (tagsList != null) {
        tags = tagsList.map((t) => t.toString()).toList();
      }
    } catch (_) {}

    return ProductModel(
      id: node['id'] as String,
      title: (node['title'] as String?) ?? '',
      handle: (node['handle'] as String?) ?? '',
      description: node['description'] as String?,
      imageUrl: imageUrl,
      variantId: variantId,
      price: price,
      compareAtPrice: compareAtPrice,
      vendor: node['vendor'] as String?,
      productType: node['productType'] as String?,
      tags: tags,
      availableForSale: node['availableForSale'] as bool? ?? true,
      minPrice: minPrice,
      maxPrice: maxPrice,
      currencyCode: currencyCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'handle': handle,
        'description': description,
        'imageUrl': imageUrl,
        'variantId': variantId,
        'price': price,
        'compareAtPrice': compareAtPrice,
        'vendor': vendor,
        'productType': productType,
        'tags': tags,
        'availableForSale': availableForSale,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'currencyCode': currencyCode,
      };

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, handle: $handle, price: $price, vendor: $vendor)';
  }
}