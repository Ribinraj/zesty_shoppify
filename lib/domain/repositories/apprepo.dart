// lib/repository/app_repo.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zestyvibe/data/models/bannermodel.dart';
import 'package:zestyvibe/data/models/cartItem_model.dart';
import 'package:zestyvibe/data/models/collection_model.dart';

import 'package:zestyvibe/data/models/order_modelitem.dart';
import 'package:zestyvibe/data/models/product_detail_model.dart';
import 'package:zestyvibe/data/models/product_model.dart';
import 'package:zestyvibe/domain/token_storage.dart';

import 'package:zestyvibe/core/urls.dart';
import 'package:zestyvibe/core/credentials.dart';

class ApiResponse<T> {
  final T? data;
  final String message;
  final bool error;
  final int status;

  ApiResponse({
    this.data,
    required this.message,
    required this.error,
    required this.status,
  });
}

/// Small container for paginated products returned by fetchProducts()
class PaginatedProducts {
  final List<ProductModel> products;
  final bool hasNextPage;
  final String? endCursor;

  PaginatedProducts({
    required this.products,
    required this.hasNextPage,
    required this.endCursor,
  });
}

class AppRepo {
  static AppRepo? _instance;
  static AppRepo get instance {
    if (_instance == null)
      throw Exception('AppRepo not initialized. Call AppRepo.init() first.');
    return _instance!;
  }

  final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  // Toggle this to false for production to avoid verbose logs
  final bool _debug = true;

  String? _storeDomain;
  String? _storefrontToken;

  AppRepo._internal({required this.dio});

  /// Initialize AppRepo. It reads domain/storefront token and customer token from secure storage.
  static Future<void> init({Dio? dio}) async {
    if (_instance != null) return;

    final tokenStorage = TokenStorage();
    final storedDomain = await tokenStorage.readDomain();
    final storedToken = await tokenStorage.readToken();
    final storedCustomerToken = await tokenStorage.readCustomerToken();

    final domain = storedDomain ?? Credentials.storeDomain;
    final token = storedToken ?? Credentials.storefrontToken;

    final baseUrl = domain.isNotEmpty
        ? 'https://$domain/api/${Urls.apiVersion}/graphql.json'
        : Urls.baseUrl;

    final options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty && token != '<PASTE_YOUR_STOREFRONT_TOKEN_HERE>')
          'X-Shopify-Storefront-Access-Token': token,
        // customer token set below if available
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );

    final usedDio = dio ?? Dio(options);

    // apply customer token if stored
    if (storedCustomerToken != null && storedCustomerToken.isNotEmpty) {
      usedDio.options.headers['X-Shopify-Customer-Access-Token'] = storedCustomerToken;
    }

    _instance = AppRepo._internal(dio: usedDio);
    _instance!._storeDomain = domain.isNotEmpty ? domain : null;
    _instance!._storefrontToken = (token.isNotEmpty && token != '<PASTE_YOUR_STOREFRONT_TOKEN_HERE>') ? token : null;
  }

  bool get hasCredentials => _storeDomain != null && _storefrontToken != null;

  Future<void> setDomainAndToken({
    required String domain,
    required String token,
  }) async {
    await _tokenStorage.save(domain, token);
    _storeDomain = domain;
    _storefrontToken = token;
    dio.options.baseUrl = 'https://$domain/api/${Urls.apiVersion}/graphql.json';
    dio.options.headers['X-Shopify-Storefront-Access-Token'] = token;
  }

  Future<void> clearCredentials() async {
    await _tokenStorage.deleteDomain();
    await _tokenStorage.deleteToken();
    _storeDomain = null;
    _storefrontToken = null;
    dio.options.headers.remove('X-Shopify-Storefront-Access-Token');
    dio.options.baseUrl = Urls.baseUrl;
  }

  Future<ApiResponse<dynamic>> graphQL(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      if (_debug) {
        debugPrint('--- GraphQL REQUEST ---');
        debugPrint(query.replaceAll('\n', ' '));
        if (variables != null && variables.isNotEmpty) {
          debugPrint('Variables: $variables');
        }
      }

      final res = await dio.post(
        "",
        data: {'query': query, if (variables != null) 'variables': variables},
      );

      if (_debug) {
        debugPrint('--- GraphQL RAW RESPONSE ---');
        debugPrint(res.data?.toString() ?? '<<no data>>');
      }

      final data = res.data as Map<String, dynamic>;

      if (data['errors'] != null) {
        final message = (data['errors'] as List).isNotEmpty ? data['errors'][0]['message'] : 'GraphQL error';
        if (_debug) debugPrint('GraphQL ERRORS: ${data['errors']}');
        return ApiResponse(data: null, message: message ?? 'GraphQL error', error: true, status: 400);
      }

      return ApiResponse(data: data['data'], message: 'Success', error: false, status: 200);
    } on DioException catch (e) {
      if (_debug) debugPrint('DioException: ${e.message} ${e.response?.statusCode} ${e.response?.data}');
      log(e.toString());
      final status = e.response?.statusCode ?? 500;
      final msg = e.response?.data != null ? e.response!.data.toString() : 'Network or server error occurred';
      return ApiResponse(data: null, message: msg, error: true, status: status);
    } catch (e, s) {
      if (_debug) debugPrint('Unexpected error: $e');
      log('$e\n$s');
      return ApiResponse(data: null, message: 'Unexpected error', error: true, status: 500);
    }
  }


  Future<ApiResponse<ProductDetailModel>> fetchProductByHandle({
    required String handle,
  }) async {
    const query = r'''
      query ProductByHandle($handle: String!) {
        productByHandle(handle: $handle) {
          id
          title
          handle
          descriptionHtml
          images(first: 10) {
            edges {
              node {
                url
                altText
                width
                height
              }
            }
          }
          variants(first: 50) {
            edges {
              node {
                id
                title
                sku
                availableForSale
                selectedOptions {
                  name
                  value
                }
                price {
                  amount
                  currencyCode
                }
                image {
                  url
                  altText
                }
              }
            }
          }
        }
      }
    ''';

    final resp = await graphQL(query, variables: {'handle': handle});
    if (resp.error) {
      if (_debug) debugPrint('fetchProductByHandle error for handle=$handle : ${resp.message}');
      return ApiResponse(
        data: null,
        message: resp.message,
        error: true,
        status: resp.status,
      );
    }

    final productData = resp.data?['productByHandle'];
    if (productData == null) {
      if (_debug) debugPrint('ProductByHandle returned null for handle: $handle. Full data: ${resp.data}');
      return ApiResponse(
        data: null,
        message: 'Product not found',
        error: true,
        status: 404,
      );
    }

    try {
      final model = ProductDetailModel.fromGraphQL(productData as Map<String, dynamic>);
      return ApiResponse(
        data: model,
        message: 'Success',
        error: false,
        status: 200,
      );
    } catch (e, s) {
      if (_debug) {
        debugPrint('Parsing product detail failed: $e');
        debugPrint('Raw product map: $productData');
      }
      log('$e\n$s');
      return ApiResponse(
        data: null,
        message: 'Parsing product data failed',
        error: true,
        status: 500,
      );
    }
  }
  ///////////////////cart///////////////////////////////
    static const String _kLocalCartKey = '_local_cart_id';

  Future<void> _saveLocalCartId(String id) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kLocalCartKey, id);
    } catch (_) {}
  }

  Future<String?> _readLocalCartId() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_kLocalCartKey);
    } catch (_) {
      return null;
    }
  }

  /// PUBLIC method to clear locally stored cart ID
  Future<void> clearLocalCartId() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kLocalCartKey);
    } catch (_) {}
  }


  /// Create a new cart with optional initial lines.
  Future<ApiResponse<CartModel>> createCart({
    List<Map<String, dynamic>>? lines, // each { merchandiseId: gid, quantity: int }
  }) async {
    const mutation = r'''
      mutation cartCreate($input: CartInput!) {
        cartCreate(input: $input) {
          cart {
            id
            checkoutUrl
            totalQuantity
            estimatedCost { totalAmount { amount currencyCode } }
            lines(first: 100) { edges { node { id quantity merchandise { ... on ProductVariant { id title product { title } image { url } price { amount currencyCode } } } } } }
          }
          userErrors { field message }
        }
      }
    ''';

    final input = <String, dynamic>{};
    if (lines != null && lines.isNotEmpty) input['lines'] = lines;

    final resp = await graphQL(mutation, variables: {'input': input});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['cartCreate'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['userErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) {
      final msg = (errors.first['message'] ?? 'Cart create error').toString();
      return ApiResponse(data: null, message: msg, error: true, status: 400);
    }

    final cartMap = payload['cart'] as Map<String, dynamic>?;
    if (cartMap == null) return ApiResponse(data: null, message: 'No cart object', error: true, status: 500);

    final cart = CartModel.fromGraphQL(cartMap);
    await _saveLocalCartId(cart.id);
    return ApiResponse(data: cart, message: 'Success', error: false, status: 200);
  }

  /// Fetch cart by id (id from local or supplied)
  Future<ApiResponse<CartModel>> fetchCart({String? cartId}) async {
    final id = cartId ?? await _readLocalCartId();
    if (id == null) return ApiResponse(data: null, message: 'No cart id', error: true, status: 404);

    const query = r'''
      query getCart($id: ID!) {
        cart(id: $id) {
          id
          checkoutUrl
          totalQuantity
          estimatedCost { totalAmount { amount currencyCode } }
          lines(first: 250) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product { title }
                    image { url }
                    price { amount currencyCode }
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final resp = await graphQL(query, variables: {'id': id});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final cartMap = resp.data?['cart'] as Map<String, dynamic>?;
    if (cartMap == null) return ApiResponse(data: null, message: 'Cart not found', error: true, status: 404);

    final cart = CartModel.fromGraphQL(cartMap);
    return ApiResponse(data: cart, message: 'Success', error: false, status: 200);
  }

  /// Add lines to cart
  Future<ApiResponse<CartModel>> addLines({
    required String cartId,
    required List<Map<String, dynamic>> lines, // [{ merchandiseId, quantity }]
  }) async {
    const mutation = r'''
      mutation cartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
        cartLinesAdd(cartId: $cartId, lines: $lines) {
          cart {
            id
            checkoutUrl
            totalQuantity
            estimatedCost { totalAmount { amount currencyCode } }
            lines(first: 250) {
              edges { node {
                id quantity merchandise { ... on ProductVariant { id title product { title } image { url } price { amount currencyCode } } }
              } }
            }
          }
          userErrors { field message }
        }
      }
    ''';

    final resp = await graphQL(mutation, variables: {'cartId': cartId, 'lines': lines});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['cartLinesAdd'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['userErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) return ApiResponse(data: null, message: errors.first['message'] ?? 'Error', error: true, status: 400);

    final cartMap = payload['cart'] as Map<String, dynamic>?;
    if (cartMap == null) return ApiResponse(data: null, message: 'No cart object', error: true, status: 500);

    final cart = CartModel.fromGraphQL(cartMap);
    await _saveLocalCartId(cart.id);
    return ApiResponse(data: cart, message: 'Success', error: false, status: 200);
  }

  /// Update cart lines (each item: {id: cartLineId, quantity: int})
  Future<ApiResponse<CartModel>> updateLines({
    required String cartId,
    required List<Map<String, dynamic>> lines,
  }) async {
    const mutation = r'''
      mutation cartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
        cartLinesUpdate(cartId: $cartId, lines: $lines) {
          cart {
            id
            checkoutUrl
            totalQuantity
            estimatedCost { totalAmount { amount currencyCode } }
            lines(first: 250) {
              edges { node {
                id quantity merchandise { ... on ProductVariant { id title product { title } image { url } price { amount currencyCode } } }
              } }
            }
          }
          userErrors { field message }
        }
      }
    ''';

    final resp = await graphQL(mutation, variables: {'cartId': cartId, 'lines': lines});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['cartLinesUpdate'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['userErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) return ApiResponse(data: null, message: errors.first['message'] ?? 'Error', error: true, status: 400);

    final cartMap = payload['cart'] as Map<String, dynamic>?;
    if (cartMap == null) return ApiResponse(data: null, message: 'No cart object', error: true, status: 500);

    final cart = CartModel.fromGraphQL(cartMap);
    return ApiResponse(data: cart, message: 'Success', error: false, status: 200);
  }

  /// Remove cart lines by their cartLineIds
  Future<ApiResponse<CartModel>> removeLines({
    required String cartId,
    required List<String> lineIds,
  }) async {
    const mutation = r'''
      mutation cartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
        cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
          cart {
            id
            checkoutUrl
            totalQuantity
            estimatedCost { totalAmount { amount currencyCode } }
            lines(first: 250) {
              edges { node {
                id quantity merchandise { ... on ProductVariant { id title product { title } image { url } price { amount currencyCode } } }
              } }
            }
          }
          userErrors { field message }
        }
      }
    ''';

    final resp = await graphQL(mutation, variables: {'cartId': cartId, 'lineIds': lineIds});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['cartLinesRemove'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['userErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) return ApiResponse(data: null, message: errors.first['message'] ?? 'Error', error: true, status: 400);

    final cartMap = payload['cart'] as Map<String, dynamic>?;
    if (cartMap == null) return ApiResponse(data: null, message: 'No cart object', error: true, status: 500);

    final cart = CartModel.fromGraphQL(cartMap);
    if (cart.totalQuantity == 0) await clearLocalCartId();
    return ApiResponse(data: cart, message: 'Success', error: false, status: 200);
  }
///////-----------searchproduct--------------///////////////
///  /// Search products with optional cursor-based pagination.
  /// Uses the same PaginatedProducts container so UI pagination is identical.
  Future<ApiResponse<PaginatedProducts>> searchProducts({
    required String query,
    int first = 12,
    String? after,
  }) async {
    const searchQuery = r'''
      query SearchProducts($query: String!, $first: Int!, $after: String) {
        products(first: $first, query: $query, after: $after) {
          edges {
            node {
              id
              title
              handle
              description
              images(first:1) {
                edges { node { url altText } }
              }
              variants(first:1) {
                edges {
                  node {
                    id
                    title
                    sku
                    price {
                      amount
                      currencyCode
                    }
                  }
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    ''';

    final resp = await graphQL(searchQuery, variables: {'query': query, 'first': first, if (after != null) 'after': after});
    if (resp.error) {
      return ApiResponse(
        data: null,
        message: resp.message,
        error: true,
        status: resp.status,
      );
    }

    final productsData = resp.data?['products'] ?? {};
    final extracted = (productsData['edges'] as List<dynamic>?) ?? [];
    final products = extracted.map<ProductModel>((e) {
      final node = e['node'] as Map<String, dynamic>;
      return ProductModel.fromGraphQL(node);
    }).toList();

    final pageInfo = productsData['pageInfo'] as Map<String, dynamic>?;

    final paginated = PaginatedProducts(
      products: products,
      hasNextPage: pageInfo?['hasNextPage'] as bool? ?? false,
      endCursor: pageInfo?['endCursor'] as String?,
    );

    return ApiResponse(
      data: paginated,
      message: 'Success',
      error: false,
      status: 200,
    );
  }
    // ------------------ Customer / Auth Methods ------------------

  /// Register a new customer (sign up)
  Future<ApiResponse<Map<String, dynamic>>> registerCustomer({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
  }) async {
    const mutation = r'''
      mutation customerCreate($input: CustomerCreateInput!) {
        customerCreate(input: $input) {
          customer {
            id
            firstName
            lastName
            email
          }
          customerUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    final input = {
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'email': email,
      'password': password,
    };

    final resp = await graphQL(mutation, variables: {'input': input});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['customerCreate'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['customerUserErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) {
      final msg = (errors.first['message'] ?? 'Customer create error').toString();
      return ApiResponse(data: null, message: msg, error: true, status: 400);
    }

    final customer = payload['customer'] as Map<String, dynamic>?;
    if (customer == null) return ApiResponse(data: null, message: 'No customer returned', error: true, status: 500);

    return ApiResponse(data: customer, message: 'Success', error: false, status: 200);
  }

  /// Create a customer access token (login)
  Future<ApiResponse<Map<String, dynamic>>> loginCustomer({
    required String email,
    required String password,
    bool persistToken = true,
  }) async {
    const mutation = r'''
      mutation customerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) {
        customerAccessTokenCreate(input: $input) {
          customerAccessToken {
            accessToken
            expiresAt
          }
          customerUserErrors {
            message
            field
            code
          }
        }
      }
    ''';

    final input = {'email': email, 'password': password};
    final resp = await graphQL(mutation, variables: {'input': input});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['customerAccessTokenCreate'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['customerUserErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) {
      final msg = (errors.first['message'] ?? 'Login failed').toString();
      return ApiResponse(data: null, message: msg, error: true, status: 400);
    }

    final tokenObj = payload['customerAccessToken'] as Map<String, dynamic>?;
    if (tokenObj == null) return ApiResponse(data: null, message: 'No token returned', error: true, status: 500);

    final accessToken = tokenObj['accessToken'] as String?;
    if (accessToken == null) return ApiResponse(data: null, message: 'No access token', error: true, status: 500);

    if (persistToken) {
      await _tokenStorage.saveCustomerToken(accessToken, expiresAt: tokenObj['expiresAt']?.toString());
      dio.options.headers['X-Shopify-Customer-Access-Token'] = accessToken;
    }

    return ApiResponse(data: tokenObj, message: 'Success', error: false, status: 200);
  }

  /// Delete customer access token (logout)
  Future<ApiResponse<void>> logoutCustomer({String? accessToken}) async {
    final token = accessToken ?? await _tokenStorage.readCustomerToken();
    if (token == null) return ApiResponse(data: null, message: 'No customer token', error: true, status: 400);

    const mutation = r'''
      mutation customerAccessTokenDelete($customerAccessToken: String!) {
        customerAccessTokenDelete(customerAccessToken: $customerAccessToken) {
          deletedAccessToken
          userErrors { field message }
        }
      }
    ''';

    final resp = await graphQL(mutation, variables: {'customerAccessToken': token});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final payload = resp.data?['customerAccessTokenDelete'];
    if (payload == null) return ApiResponse(data: null, message: 'Invalid response', error: true, status: 500);

    final errors = payload['userErrors'] as List<dynamic>? ?? [];
    if (errors.isNotEmpty) {
      return ApiResponse(data: null, message: errors.first['message'] ?? 'Error', error: true, status: 400);
    }

    await _tokenStorage.deleteCustomerToken();
    dio.options.headers.remove('X-Shopify-Customer-Access-Token');

    return ApiResponse(data: null, message: 'Success', error: false, status: 200);
  }

  /// Fetch current customer profile using customerAccessToken
  Future<ApiResponse<Map<String, dynamic>>> fetchCustomer({String? accessToken}) async {
    final token = accessToken ?? await _tokenStorage.readCustomerToken();
    if (token == null) return ApiResponse(data: null, message: 'No customer token', error: true, status: 400);

    const query = r'''
      query customerQuery($token: String!) {
        customer(customerAccessToken: $token) {
          id
          email
          firstName
          lastName
          phone
          defaultAddress {
            address1
            city
            country
            zip
          }
          acceptsMarketing
        }
      }
    ''';

    final resp = await graphQL(query, variables: {'token': token});
    if (resp.error) return ApiResponse(data: null, message: resp.message, error: true, status: resp.status);

    final customer = resp.data?['customer'] as Map<String, dynamic>?;
    if (customer == null) return ApiResponse(data: null, message: 'Customer not found', error: true, status: 404);

    return ApiResponse(data: customer, message: 'Success', error: false, status: 200);
  }

  // --------- helper to set/clear customer token manually ---------
  Future<void> setCustomerAccessToken(String token) async {
    await _tokenStorage.saveCustomerToken(token);
    dio.options.headers['X-Shopify-Customer-Access-Token'] = token;
  }

  Future<void> clearCustomerAccessToken() async {
    await _tokenStorage.deleteCustomerToken();
    dio.options.headers.remove('X-Shopify-Customer-Access-Token');
  }
/// Fetch customer orders (requires customer access token)
Future<ApiResponse<List<OrderModel>>> fetchCustomerOrders({
  int first = 10,
  String? after,
}) async {
  final token = await _tokenStorage.readCustomerToken();
  if (token == null) {
    return ApiResponse(
      data: null,
      message: 'Not logged in',
      error: true,
      status: 401,
    );
  }

const query = r'''
  query getCustomerOrders($token: String!, $first: Int!, $after: String) {
    customer(customerAccessToken: $token) {
      orders(first: $first, after: $after, sortKey: PROCESSED_AT, reverse: true) {
        edges {
          node {
            id
            name
            orderNumber
            processedAt
            financialStatus
            fulfillmentStatus
            statusUrl
            email
            totalPriceV2 { amount currencyCode }
            shippingAddress { address1 city province zip country }
            lineItems(first: 50) {
              edges {
                node {
                  title
                  quantity
                  originalTotalPrice { amount currencyCode }
                  variant {
                    id
                    title
                    image { url }
                    product { title }
                  }
                }
              }
            }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
''';


  final resp = await graphQL(
    query,
    variables: {
      'token': token,
      'first': first,
      if (after != null) 'after': after,
    },
  );

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final customer = resp.data?['customer'];
  if (customer == null) {
    return ApiResponse(
      data: null,
      message: 'Customer not found or token expired',
      error: true,
      status: 404,
    );
  }

  final ordersData = customer['orders'] ?? {};
  final edges = (ordersData['edges'] as List<dynamic>?) ?? [];
  
  final orders = edges.map<OrderModel>((e) {
    final node = e['node'] as Map<String, dynamic>;
    return OrderModel.fromGraphQL(node);
  }).toList();

  return ApiResponse(
    data: orders,
    message: 'Success',
    error: false,
    status: 200,
  );
}
// In AppRepo class

/// Update current logged-in customer's profile
Future<ApiResponse<Map<String, dynamic>>> updateCustomerProfile({
  String? firstName,
  String? lastName,
  String? phone,
  bool? acceptsMarketing,
}) async {
  // Need customer token
  final token = await _tokenStorage.readCustomerToken();
  if (token == null) {
    return ApiResponse(
      data: null,
      message: 'No customer token',
      error: true,
      status: 401,
    );
  }

  // Build input object only with non-null fields
  final customerInput = <String, dynamic>{};
  if (firstName != null) customerInput['firstName'] = firstName;
  if (lastName != null) customerInput['lastName'] = lastName;
  if (phone != null) customerInput['phone'] = phone;
  if (acceptsMarketing != null) {
    customerInput['acceptsMarketing'] = acceptsMarketing;
  }

  if (customerInput.isEmpty) {
    return ApiResponse(
      data: null,
      message: 'Nothing to update',
      error: true,
      status: 400,
    );
  }

  const mutation = r'''
    mutation customerUpdate($customerAccessToken: String!, $customer: CustomerUpdateInput!) {
      customerUpdate(customerAccessToken: $customerAccessToken, customer: $customer) {
        customer {
          id
          email
          firstName
          lastName
          phone
          defaultAddress {
            address1
            city
            country
            zip
          }
          acceptsMarketing
        }
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

  final resp = await graphQL(
    mutation,
    variables: {
      'customerAccessToken': token,
      'customer': customerInput,
    },
  );

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final payload = resp.data?['customerUpdate'];
  if (payload == null) {
    return ApiResponse(
      data: null,
      message: 'Invalid response',
      error: true,
      status: 500,
    );
  }

  final errors = payload['customerUserErrors'] as List<dynamic>? ?? [];
  if (errors.isNotEmpty) {
    final msg = (errors.first['message'] ?? 'Update failed').toString();
    return ApiResponse(
      data: null,
      message: msg,
      error: true,
      status: 400,
    );
  }

  final customer = payload['customer'] as Map<String, dynamic>?;
  if (customer == null) {
    return ApiResponse(
      data: null,
      message: 'No customer returned',
      error: true,
      status: 500,
    );
  }

  // same style as fetchCustomer / registerCustomer etc.
  return ApiResponse(
    data: customer,
    message: 'Success',
    error: false,
    status: 200,
  );
}

/// Fetch single order details
Future<ApiResponse<OrderModel>> fetchOrderById({
  required String orderId,
}) async {
  final token = await _tokenStorage.readCustomerToken();
  if (token == null) {
    return ApiResponse(
      data: null,
      message: 'Not logged in',
      error: true,
      status: 401,
    );
  }

  const query = r'''
    query getOrder($token: String!) {
      customer(customerAccessToken: $token) {
        orders(first: 250) {
          edges {
            node {
              id
              name
              orderNumber
              processedAt
              financialStatus
              fulfillmentStatus
              statusUrl
              email
              totalPriceV2 {
                amount
                currencyCode
              }
              shippingAddress {
                address1
                city
                province
                zip
                country
              }
              lineItems(first: 50) {
                edges {
                  node {
                    title
                    variantTitle
                    quantity
                    originalTotalPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  final resp = await graphQL(query, variables: {'token': token});

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final customer = resp.data?['customer'];
  if (customer == null) {
    return ApiResponse(
      data: null,
      message: 'Customer not found',
      error: true,
      status: 404,
    );
  }

  final ordersData = customer['orders'] ?? {};
  final edges = (ordersData['edges'] as List<dynamic>?) ?? [];
  
  // Find the specific order
  final orderNode = edges.firstWhere(
    (e) => (e['node'] as Map<String, dynamic>)['id'] == orderId,
    orElse: () => null,
  );

  if (orderNode == null) {
    return ApiResponse(
      data: null,
      message: 'Order not found',
      error: true,
      status: 404,
    );
  }

  final order = OrderModel.fromGraphQL(orderNode['node'] as Map<String, dynamic>);

  return ApiResponse(
    data: order,
    message: 'Success',
    error: false,
    status: 200,
  );
}
/// Fetch collections with pagination
/// Fetch collections with pagination - IMPROVED VERSION
Future<ApiResponse<List<CollectionModel>>> fetchCollections({
  int first = 10,
  String? after,
}) async {
  const query = r'''
    query Collections($first: Int!, $after: String) {
      collections(first: $first, after: $after) {
        edges {
          node {
            id
            title
            handle
            description
            image {
              url
              altText
            }
            products(first: 250) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';

  final resp = await graphQL(query, variables: {
    'first': first,
    if (after != null) 'after': after,
  });

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final collectionsData = resp.data?['collections'] ?? {};
  final extracted = (collectionsData['edges'] as List<dynamic>?) ?? [];
  
  final collections = extracted.map<CollectionModel>((e) {
    final node = e['node'] as Map<String, dynamic>;
    return CollectionModel.fromGraphQL(node);
  }).toList();

  return ApiResponse(
    data: collections,
    message: 'Success',
    error: false,
    status: 200,
  );
}

/// Fetch products by collection with filters and sorting
Future<ApiResponse<PaginatedProducts>> fetchProductsByCollection({
  required String collectionHandle,
  int first = 12,
  String? after,
  ProductSortKey sortKey = ProductSortKey.relevance,
  ProductFilter? filters,
}) async {
  const query = r'''
    query CollectionProducts($handle: String!, $first: Int!, $after: String, $sortKey: ProductCollectionSortKeys, $filters: [ProductFilter!]) {
      collection(handle: $handle) {
        products(first: $first, after: $after, sortKey: $sortKey, filters: $filters) {
          edges {
            node {
              id
              title
              handle
              description
              vendor
              productType
              tags
              availableForSale
              images(first: 1) {
                edges {
                  node {
                    url
                    altText
                  }
                }
              }
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
                maxVariantPrice {
                  amount
                  currencyCode
                }
              }
              variants(first: 1) {
                edges {
                  node {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                  }
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  ''';

  final variables = <String, dynamic>{
    'handle': collectionHandle,
    'first': first,
    if (after != null) 'after': after,
    'sortKey': sortKey.value,
    if (filters != null) 'filters': [filters.toJson()],
  };

  final resp = await graphQL(query, variables: variables);

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final collection = resp.data?['collection'];
  if (collection == null) {
    return ApiResponse(
      data: null,
      message: 'Collection not found',
      error: true,
      status: 404,
    );
  }

  final productsData = collection['products'] ?? {};
  final extracted = (productsData['edges'] as List<dynamic>?) ?? [];
  
  final products = extracted.map<ProductModel>((e) {
    final node = e['node'] as Map<String, dynamic>;
    return ProductModel.fromGraphQL(node);
  }).toList();

  final pageInfo = productsData['pageInfo'] as Map<String, dynamic>?;

  final paginated = PaginatedProducts(
    products: products,
    hasNextPage: pageInfo?['hasNextPage'] as bool? ?? false,
    endCursor: pageInfo?['endCursor'] as String?,
  );

  return ApiResponse(
    data: paginated,
    message: 'Success',
    error: false,
    status: 200,
  );
}

/// Updated fetchProducts with sorting support
Future<ApiResponse<PaginatedProducts>> fetchProducts({
  int first = 12,
  String? after,
  ProductSortKey sortKey = ProductSortKey.relevance,
  ProductFilter? filters,
}) async {
  const query = r'''
    query Products($first: Int!, $after: String, $sortKey: ProductSortKeys, $query: String) {
      products(first: $first, after: $after, sortKey: $sortKey, query: $query) {
        edges {
          node {
            id
            title
            handle
            description
            vendor
            productType
            tags
            availableForSale
            images(first: 1) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
              maxVariantPrice {
                amount
                currencyCode
              }
            }
            variants(first: 1) {
              edges {
                node {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';

  // Build query string from filters
  String? queryString;
  if (filters != null) {
    final parts = <String>[];
    if (filters.available != null) {
      parts.add('available_for_sale:${filters.available}');
    }
    if (filters.productType != null) {
      parts.add('product_type:"${filters.productType}"');
    }
    if (filters.vendor != null) {
      parts.add('vendor:"${filters.vendor}"');
    }
    if (filters.price != null) {
      parts.add('variants.price:>=${filters.price!.min}');
      parts.add('variants.price:<=${filters.price!.max}');
    }
    if (filters.tags != null && filters.tags!.isNotEmpty) {
      for (final tag in filters.tags!) {
        parts.add('tag:"$tag"');
      }
    }
    if (parts.isNotEmpty) {
      queryString = parts.join(' AND ');
    }
  }

  final resp = await graphQL(query, variables: {
    'first': first,
    if (after != null) 'after': after,
    'sortKey': sortKey.value,
    if (queryString != null) 'query': queryString,
  });

  if (resp.error || resp.data == null) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final productsData = resp.data?['products'] ?? {};
  final extracted = (productsData['edges'] as List<dynamic>?) ?? [];
  
  final products = extracted.map<ProductModel>((e) {
    final node = e['node'] as Map<String, dynamic>;
    return ProductModel.fromGraphQL(node);
  }).toList();

  final pageInfo = productsData['pageInfo'] as Map<String, dynamic>?;

  final paginated = PaginatedProducts(
    products: products,
    hasNextPage: pageInfo?['hasNextPage'] as bool? ?? false,
    endCursor: pageInfo?['endCursor'] as String?,
  );

  return ApiResponse(
    data: paginated,
    message: 'Success',
    error: false,
    status: 200,
  );
}


Future<ApiResponse<List<BannerModel>>> fetchBannersFromCollections() async {
  const query = r'''
    query {
      collections(first: 5, query: "featured:true") {
        edges {
          node {
            id
            title
            handle
            description
            image {
              url
              altText
            }
          }
        }
      }
    }
  ''';

  if (_debug) debugPrint('--- FETCHING BANNERS FROM COLLECTIONS ---');
  
  final resp = await graphQL(query);

  if (resp.error) {
    if (_debug) debugPrint('❌ fetchBannersFromCollections error: ${resp.message}');
    return _getMockBanners();
  }

  try {
    final edges = resp.data?['collections']?['edges'] as List<dynamic>?;
    
    if (edges == null || edges.isEmpty) {
      if (_debug) debugPrint('⚠️ No featured collections found');
      return _getMockBanners();
    }

    final banners = <BannerModel>[];
    
    for (var i = 0; i < edges.length; i++) {
      final node = edges[i]['node'] as Map<String, dynamic>;
      final image = node['image'] as Map<String, dynamic>?;
      
      if (image != null && image['url'] != null) {
        banners.add(BannerModel(
          id: node['id']?.toString() ?? 'banner_$i',
          imageUrl: image['url']?.toString() ?? '',
          title: node['title']?.toString() ?? 'Collection',
          subtitle: node['description']?.toString() ?? 'Explore our products',
          actionText: 'Shop Collection',
          actionHandle: node['handle']?.toString(),
          order: i,
        ));
      }
    }

    if (_debug) debugPrint('✅ Created ${banners.length} banners from collections');

    return ApiResponse(
      data: banners,
      message: 'Success',
      error: false,
      status: 200,
    );
  } catch (e, s) {
    if (_debug) {
      debugPrint('❌ Failed to parse collection banners: $e');
      debugPrint('Stack trace: $s');
    }
    return _getMockBanners();
  }
}

// Helper method for mock banners (same as before)
ApiResponse<List<BannerModel>> _getMockBanners() {
  if (_debug) debugPrint('🎨 Using mock banners for testing');
  
  final mockBanners = [
    BannerModel(
      id: 'banner_1',
      imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
      title: 'Fresh Organic Products',
      subtitle: 'Get 20% off on your first order',
      actionText: 'Shop Now',
      actionHandle: null,
      order: 1,
    ),
    BannerModel(
      id: 'banner_2',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      title: 'Premium Quality',
      subtitle: 'Sourced directly from farms',
      actionText: 'Explore',
      actionHandle: null,
      order: 2,
    ),
    BannerModel(
      id: 'banner_3',
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&q=80',
      title: 'Special Deals',
      subtitle: 'Limited time offers on selected items',
      actionText: 'View Deals',
      actionHandle: null,
      order: 3,
    ),
  ];

  return ApiResponse(
    data: mockBanners,
    message: 'Using mock banners',
    error: false,
    status: 200,
  );
}
/// Create a new address for the logged-in customer
Future<ApiResponse<Map<String, dynamic>>> createCustomerAddress({
  required String address1,
  String? address2,
  String? city,
  String? province,
  String? zip,
  String? country,
}) async {
  final token = await _tokenStorage.readCustomerToken();
  if (token == null) {
    return ApiResponse(
      data: null,
      message: 'Not logged in',
      error: true,
      status: 401,
    );
  }

  const mutation = r'''
    mutation customerAddressCreate($customerAccessToken: String!, $address: MailingAddressInput!) {
      customerAddressCreate(customerAccessToken: $customerAccessToken, address: $address) {
        customerAddress {
          id
          address1
          city
          country
          zip
        }
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

  final addressInput = <String, dynamic>{
    'address1': address1,
    if (address2 != null && address2.isNotEmpty) 'address2': address2,
    if (city != null && city.isNotEmpty) 'city': city,
    if (province != null && province.isNotEmpty) 'province': province,
    if (zip != null && zip.isNotEmpty) 'zip': zip,
    if (country != null && country.isNotEmpty) 'country': country,
  };

  final resp = await graphQL(
    mutation,
    variables: {
      'customerAccessToken': token,
      'address': addressInput,
    },
  );

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final payload = resp.data?['customerAddressCreate'];
  if (payload == null) {
    return ApiResponse(
      data: null,
      message: 'Invalid response',
      error: true,
      status: 500,
    );
  }

  final errors = payload['customerUserErrors'] as List<dynamic>? ?? [];
  if (errors.isNotEmpty) {
    final msg = (errors.first['message'] ?? 'Address create failed').toString();
    return ApiResponse(
      data: null,
      message: msg,
      error: true,
      status: 400,
    );
  }

  final address = payload['customerAddress'] as Map<String, dynamic>?;
  if (address == null) {
    return ApiResponse(
      data: null,
      message: 'No address returned',
      error: true,
      status: 500,
    );
  }

  return ApiResponse(
    data: address,
    message: 'Success',
    error: false,
    status: 200,
  );
}
/// Set an address as the customer's default address
Future<ApiResponse<Map<String, dynamic>>> setDefaultCustomerAddress({
  required String addressId,
}) async {
  final token = await _tokenStorage.readCustomerToken();
  if (token == null) {
    return ApiResponse(
      data: null,
      message: 'Not logged in',
      error: true,
      status: 401,
    );
  }

  const mutation = r'''
    mutation customerDefaultAddressUpdate($customerAccessToken: String!, $addressId: ID!) {
      customerDefaultAddressUpdate(customerAccessToken: $customerAccessToken, addressId: $addressId) {
        customer {
          id
          defaultAddress {
            address1
            city
            country
            zip
          }
        }
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

  final resp = await graphQL(
    mutation,
    variables: {
      'customerAccessToken': token,
      'addressId': addressId,
    },
  );

  if (resp.error) {
    return ApiResponse(
      data: null,
      message: resp.message,
      error: true,
      status: resp.status,
    );
  }

  final payload = resp.data?['customerDefaultAddressUpdate'];
  if (payload == null) {
    return ApiResponse(
      data: null,
      message: 'Invalid response',
      error: true,
      status: 500,
    );
  }

  final errors = payload['customerUserErrors'] as List<dynamic>? ?? [];
  if (errors.isNotEmpty) {
    final msg = (errors.first['message'] ?? 'Set default address failed').toString();
    return ApiResponse(
      data: null,
      message: msg,
      error: true,
      status: 400,
    );
  }

  final customer = payload['customer'] as Map<String, dynamic>?;
  if (customer == null) {
    return ApiResponse(
      data: null,
      message: 'No customer returned',
      error: true,
      status: 500,
    );
  }

  return ApiResponse(
    data: customer,
    message: 'Success',
    error: false,
    status: 200,
  );
}

}
