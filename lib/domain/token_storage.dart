// lib/utils/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyToken = 'shopify_storefront_token';
  static const _keyDomain = 'shopify_store_domain';

  // Customer token keys
  static const _keyCustomerToken = 'shopify_customer_access_token';
  static const _keyCustomerExpires = 'shopify_customer_access_expires_at';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Save Domain + Storefront Access Token
  Future<void> save(String domain, String token) async {
    await Future.wait([
      _storage.write(key: _keyDomain, value: domain),
      _storage.write(key: _keyToken, value: token),
    ]);
  }

  Future<String?> readToken() => _storage.read(key: _keyToken);
  Future<String?> readDomain() => _storage.read(key: _keyDomain);

  Future<void> deleteToken() => _storage.delete(key: _keyToken);
  Future<void> deleteDomain() => _storage.delete(key: _keyDomain);

  // ----------- Customer Token Functions -------------- //

  Future<void> saveCustomerToken(String token, {String? expiresAt}) async {
    await Future.wait([
      _storage.write(key: _keyCustomerToken, value: token),
      if (expiresAt != null)
        _storage.write(key: _keyCustomerExpires, value: expiresAt),
    ]);
  }

  Future<String?> readCustomerToken() => _storage.read(key: _keyCustomerToken);
  Future<void> deleteCustomerToken() =>
      _storage.delete(key: _keyCustomerToken);

  Future<String?> readCustomerExpiresAt() =>
      _storage.read(key: _keyCustomerExpires);

  Future<void> deleteCustomerExpiresAt() =>
      _storage.delete(key: _keyCustomerExpires);

  //---------------------------------------------------//

  Future<void> clearAll() => _storage.deleteAll();
}
