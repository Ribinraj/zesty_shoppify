

/// Single line item inside an order (maps Storefront `OrderLineItem` -> `variant`)
class OrderLineItem {
  final String title;
  final String? variantId;
  final String? variantTitle;
  final String? productTitle;
  final int quantity;
  final double price; // unit price (derived from originalTotalPrice / quantity when available)
  final String? imageUrl;
  final String? currency;

  OrderLineItem({
    required this.title,
    this.variantId,
    this.variantTitle,
    this.productTitle,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.currency,
  });

  factory OrderLineItem.fromGraphQL(Map<String, dynamic> map) {
    // originalTotalPrice is the total for that line (quantity * unitPrice)
    final originalTotalMap = map['originalTotalPrice'] as Map<String, dynamic>?;
    final qty = map['quantity'] as int? ?? 1;

    double unitPrice = 0.0;
    String? currency;
    if (originalTotalMap != null) {
      final amtStr = originalTotalMap['amount']?.toString();
      final amt = double.tryParse(amtStr ?? '');
      if (amt != null && qty > 0) {
        unitPrice = amt / qty;
      } else {
        unitPrice = amt ?? 0.0;
      }
      currency = originalTotalMap['currencyCode'] as String?;
    }

    // variant may be null (e.g., variant deleted), so guard access
    final variant = map['variant'] as Map<String, dynamic>?;
    final variantId = variant?['id'] as String?;
    final variantTitle = variant?['title'] as String?;
    final productTitle = (variant?['product'] as Map<String, dynamic>?)?['title'] as String?;
    final imageUrl = (variant?['image'] as Map<String, dynamic>?)?['url'] as String?;

    return OrderLineItem(
      title: map['title'] as String? ?? '',
      variantId: variantId,
      variantTitle: variantTitle,
      productTitle: productTitle,
      quantity: qty,
      price: unitPrice,
      imageUrl: imageUrl,
      currency: currency,
    );
  }
}

/// Top-level Order model
class OrderModel {
  final String id;
  final String orderNumber;
  final String name; // e.g., "#1001"
  final DateTime processedAt;
  final String financialStatus;
  final String fulfillmentStatus;
  final double totalPrice;
  final String currencyCode;
  final List<OrderLineItem> lineItems;
  final String? statusUrl;
  final String? shippingAddress; // formatted single-line address
  final String? customerEmail;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.name,
    required this.processedAt,
    required this.financialStatus,
    required this.fulfillmentStatus,
    required this.totalPrice,
    required this.currencyCode,
    required this.lineItems,
    this.statusUrl,
    this.shippingAddress,
    this.customerEmail,
  });

  factory OrderModel.fromGraphQL(Map<String, dynamic> map) {
    // totalPriceV2
    final totalPriceMap = map['totalPriceV2'] as Map<String, dynamic>?;
    final totalPrice = totalPriceMap != null
        ? double.tryParse(totalPriceMap['amount']?.toString() ?? '') ?? 0.0
        : 0.0;
    final currencyCode = totalPriceMap?['currencyCode'] as String? ?? 'INR';

    // line items
    final lineItemsEdges = (map['lineItems']?['edges'] as List<dynamic>?) ?? [];
    final lineItems = lineItemsEdges.map<OrderLineItem>((e) {
      final node = e['node'] as Map<String, dynamic>;
      return OrderLineItem.fromGraphQL(node);
    }).toList();

    // shipping address formatting (safe)
    final shippingAddressMap = map['shippingAddress'] as Map<String, dynamic>?;
    String? formattedAddress;
    if (shippingAddressMap != null) {
      final parts = [
        shippingAddressMap['address1'],
        shippingAddressMap['city'],
        shippingAddressMap['province'],
        shippingAddressMap['zip'],
        shippingAddressMap['country'],
      ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
      formattedAddress = parts.join(', ');
    }

    // parse processedAt safely
    DateTime processedAt;
    try {
      processedAt = DateTime.parse(map['processedAt'] as String? ?? DateTime.now().toIso8601String());
    } catch (_) {
      processedAt = DateTime.now();
    }

    return OrderModel(
      id: map['id'] as String? ?? '',
      orderNumber: map['orderNumber']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      processedAt: processedAt,
      financialStatus: map['financialStatus'] as String? ?? 'UNKNOWN',
      fulfillmentStatus: map['fulfillmentStatus'] as String? ?? 'UNFULFILLED',
      totalPrice: totalPrice,
      currencyCode: currencyCode,
      lineItems: lineItems,
      statusUrl: map['statusUrl'] as String?,
      shippingAddress: formattedAddress,
      customerEmail: map['email'] as String?,
    );
  }

  String get statusText {
    switch (financialStatus.toUpperCase()) {
      case 'PAID':
        return 'Paid';
      case 'PENDING':
        return 'Payment Pending';
      case 'REFUNDED':
        return 'Refunded';
      case 'PARTIALLY_REFUNDED':
        return 'Partially Refunded';
      default:
        // fallback: prettify
        return _pretty(financialStatus);
    }
  }

  String get fulfillmentText {
    switch (fulfillmentStatus.toUpperCase()) {
      case 'FULFILLED':
        return 'Delivered';
      case 'UNFULFILLED':
        return 'Processing';
      case 'PARTIALLY_FULFILLED':
        return 'Partially Shipped';
      case 'SCHEDULED':
        return 'Scheduled';
      default:
        return _pretty(fulfillmentStatus);
    }
  }

  // small helper to make ALL_CAPS or snake-ish strings friendlier
  static String _pretty(String s) {
    if (s.trim().isEmpty) return s;
    final lower = s.toLowerCase().replaceAll('_', ' ');
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}
