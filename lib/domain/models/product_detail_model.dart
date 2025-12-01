// lib/domain/models/product_detail_model.dart
class ProductImage {
  final String url;
  final String? alt;
  final int? width;
  final int? height;

  ProductImage({required this.url, this.alt, this.width, this.height});

  factory ProductImage.fromGraphQL(Map<String, dynamic> map) {
    return ProductImage(
      url: map['url'] as String,
      alt: map['altText'] as String?,
      width: map['width'] as int?,
      height: map['height'] as int?,
    );
  }
}

class VariantOption {
  final String name;
  final String value;

  VariantOption({required this.name, required this.value});

  factory VariantOption.fromGraphQL(Map<String, dynamic> map) {
    return VariantOption(
      name: map['name'] as String,
      value: map['value'] as String,
    );
  }
}

class ProductVariant {
  final String id;
  final String title;
  final String? sku;
  final bool available;
  final List<VariantOption> selectedOptions;
  final String? imageUrl;
  final double? price;
  final String? currency;

  ProductVariant({
    required this.id,
    required this.title,
    this.sku,
    required this.available,
    this.selectedOptions = const [],
    this.imageUrl,
    this.price,
    this.currency,
  });

  factory ProductVariant.fromGraphQL(Map<String, dynamic> map) {
    final priceMap = map['price'] as Map<String, dynamic>?;
    final price = priceMap != null ? double.tryParse(priceMap['amount'].toString()) : null;
    final currency = priceMap != null ? (priceMap['currencyCode'] as String?) : null;

    return ProductVariant(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      sku: map['sku'] as String?,
      available: map['availableForSale'] as bool? ?? false,
      selectedOptions: (map['selectedOptions'] as List<dynamic>?)
              ?.map((e) => VariantOption.fromGraphQL(e as Map<String, dynamic>))
              .toList() ??
          [],
      imageUrl: (map['image'] as Map<String, dynamic>?)?['url'] as String?,
      price: price,
      currency: currency,
    );
  }
}

class ProductDetailModel {
  final String id;
  final String title;
  final String handle;
  final String? descriptionHtml;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final Map<String, String> metafields;

  ProductDetailModel({
    required this.id,
    required this.title,
    required this.handle,
    this.descriptionHtml,
    this.images = const [],
    this.variants = const [],
    this.metafields = const {},
  });

  factory ProductDetailModel.fromGraphQL(Map<String, dynamic> map) {
    final imagesEdges = (map['images']?['edges'] as List<dynamic>?) ?? [];
    final images = imagesEdges.map<ProductImage>((e) {
      final node = e['node'] as Map<String, dynamic>;
      return ProductImage.fromGraphQL(node);
    }).toList();

    final variantEdges = (map['variants']?['edges'] as List<dynamic>?) ?? [];
    final variants = variantEdges.map<ProductVariant>((e) {
      final node = e['node'] as Map<String, dynamic>;
      return ProductVariant.fromGraphQL(node);
    }).toList();

    final metafieldEdges = (map['metafields']?['edges'] as List<dynamic>?) ?? [];
    final metafields = <String, String>{};
    for (var e in metafieldEdges) {
      final node = e['node'] as Map<String, dynamic>;
      final key = '${node['namespace'] ?? ''}.${node['key'] ?? ''}';
      final val = node['value']?.toString() ?? '';
      metafields[key] = val;
    }

    return ProductDetailModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      handle: map['handle'] as String? ?? '',
      descriptionHtml: map['descriptionHtml'] as String?,
      images: images,
      variants: variants,
      metafields: metafields,
    );
  }

  ProductVariant? getVariantById(String variantId) {
    try {
      return variants.firstWhere((v) => v.id == variantId);
    } catch (e) {
      return null;
    }
  }

  ProductVariant? get defaultVariant => variants.isNotEmpty ? variants.first : null;
}
