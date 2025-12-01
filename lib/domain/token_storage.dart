// lib/utils/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyToken = 'shopify_storefront_token';
  static const _keyDomain = 'shopify_store_domain';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

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
  Future<void> clearAll() => _storage.deleteAll();
}
