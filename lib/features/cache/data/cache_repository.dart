import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return CacheRepository(ref.watch(dioProvider));
});

class CacheRepository {
  final Dio _dio;

  CacheRepository(this._dio);

  Future<void> purgeAll(String zoneId) async {
    final response = await _dio.post(
      '/zones/$zoneId/purge_cache',
      data: {'purge_everything': true},
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to purge cache: ${data['errors']}');
    }
  }
}
