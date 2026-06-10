import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/storage_models.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(dioProvider));
});

class StorageRepository {
  final Dio _dio;
  String? _cachedAccountId;

  StorageRepository(this._dio);

  Future<String> _getAccountId() async {
    if (_cachedAccountId != null) return _cachedAccountId!;

    final response = await _dio.get('/accounts');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      if (results.isEmpty) {
        throw Exception('No Cloudflare accounts found.');
      }
      _cachedAccountId = results[0]['id'] as String;
      return _cachedAccountId!;
    } else {
      throw Exception('Failed to fetch accounts: ${data['errors']}');
    }
  }

  Future<List<CloudflareKVNamespace>> getKVNamespaces() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/storage/kv/namespaces');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>? ?? [];
      return results.map((e) => CloudflareKVNamespace.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch KV namespaces: ${data['errors']}');
    }
  }

  Future<List<CloudflareD1Database>> getD1Databases() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/d1/database');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>? ?? [];
      return results.map((e) => CloudflareD1Database.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch D1 databases: ${data['errors']}');
    }
  }

  Future<List<CloudflareR2Bucket>> getR2Buckets() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/r2/buckets');
    final data = response.data;
    if (data['success'] == true) {
      final result = data['result'] as Map<String, dynamic>? ?? {};
      final buckets = result['buckets'] as List<dynamic>? ?? [];
      return buckets.map((e) => CloudflareR2Bucket.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch R2 buckets: ${data['errors']}');
    }
  }

  Future<void> createKVNamespace(String title) async {
    final accountId = await _getAccountId();
    final response = await _dio.post(
      '/accounts/$accountId/storage/kv/namespaces',
      data: {'title': title},
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to create KV namespace: ${response.data['errors']}');
    }
  }

  Future<void> updateKVNamespace(String namespaceId, String title) async {
    final accountId = await _getAccountId();
    final response = await _dio.put(
      '/accounts/$accountId/storage/kv/namespaces/$namespaceId',
      data: {'title': title},
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to update KV namespace: ${response.data['errors']}');
    }
  }

  Future<void> deleteKVNamespace(String namespaceId) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete(
      '/accounts/$accountId/storage/kv/namespaces/$namespaceId',
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to delete KV namespace: ${response.data['errors']}');
    }
  }

  Future<void> createD1Database(String name) async {
    final accountId = await _getAccountId();
    final response = await _dio.post(
      '/accounts/$accountId/d1/database',
      data: {'name': name},
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to create D1 database: ${response.data['errors']}');
    }
  }

  Future<void> deleteD1Database(String databaseId) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete(
      '/accounts/$accountId/d1/database/$databaseId',
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to delete D1 database: ${response.data['errors']}');
    }
  }

  Future<void> createR2Bucket(String name) async {
    final accountId = await _getAccountId();
    final response = await _dio.post(
      '/accounts/$accountId/r2/buckets',
      data: {'name': name},
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to create R2 bucket: ${response.data['errors']}');
    }
  }

  Future<void> deleteR2Bucket(String name) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete(
      '/accounts/$accountId/r2/buckets/$name',
    );
    if (response.data['success'] != true) {
      throw Exception('Failed to delete R2 bucket: ${response.data['errors']}');
    }
  }
}
