// lib/domain/models/cart_model.dart
class CartLineItem {
  final String id; // cart line id
  final int quantity;
  final String merchandiseId; // variant id (gid://)
  final String title; // variant title
  final String productTitle;
  final String? imageUrl;
  final double? price; // unit price
  final String? currency;

  CartLineItem({
    required this.id,
    required this.quantity,
    required this.merchandiseId,
    required this.title,
    required this.productTitle,
    this.imageUrl,
    this.price,
    this.currency,
  });

  factory CartLineItem.fromGraphQL(Map<String, dynamic> map) {
    final merchandise = map['merchandise'] as Map<String, dynamic>?;
    final priceMap = merchandise?['price'] as Map<String, dynamic>? ?? (map['cost'] as Map<String, dynamic>?);
    double? price;
    String? currency;
    if (priceMap != null) {
      price = double.tryParse(priceMap['amount']?.toString() ?? '');
      currency = priceMap['currencyCode'] as String?;
    }

    final product = merchandise?['product'] as Map<String, dynamic>?;

    return CartLineItem(
      id: map['id'] as String,
      quantity: map['quantity'] as int? ?? 0,
      merchandiseId: merchandise?['id'] as String? ?? '',
      title: merchandise?['title'] as String? ?? '',
      productTitle: product?['title'] as String? ?? '',
      imageUrl: (merchandise?['image'] as Map<String, dynamic>?)?['url'] as String?,
      price: price,
      currency: currency,
    );
  }
}

class CartModel {
  final String id;
  final String? checkoutUrl;
  final int totalQuantity;
  final double? totalAmount;
  final String? currency;
  final List<CartLineItem> lines;

  CartModel({
    required this.id,
    this.checkoutUrl,
    required this.totalQuantity,
    this.totalAmount,
    this.currency,
    this.lines = const [],
  });

  factory CartModel.fromGraphQL(Map<String, dynamic> map) {
    final linesEdges = (map['lines']?['edges'] as List<dynamic>?) ?? [];
    final lines = linesEdges.map<CartLineItem>((e) {
      final node = e['node'] as Map<String, dynamic>;
      return CartLineItem.fromGraphQL(node);
    }).toList();

    final estimatedCost = map['estimatedCost'] as Map<String, dynamic>?;
    final totalAmountMap = estimatedCost?['totalAmount'] as Map<String, dynamic>?;

    final totalAmount = totalAmountMap != null ? double.tryParse(totalAmountMap['amount']?.toString() ?? '') : null;
    final currency = totalAmountMap != null ? (totalAmountMap['currencyCode'] as String?) : null;

    return CartModel(
      id: map['id'] as String,
      checkoutUrl: map['checkoutUrl'] as String?,
      totalQuantity: map['totalQuantity'] as int? ?? 0,
      totalAmount: totalAmount,
      currency: currency,
      lines: lines,
    );
  }
}
