import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final sslRepositoryProvider = Provider<SslRepository>((ref) {
  return SslRepository(ref.watch(dioProvider));
});

class SslRepository {
  final Dio _dio;

  SslRepository(this._dio);

  Future<String> getSslMode(String zoneId) async {
    final response = await _dio.get('/zones/$zoneId/settings/ssl');
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to fetch SSL settings: ${data['errors']}');
    }
  }

  Future<String> setSslMode(String zoneId, String mode) async {
    final response = await _dio.patch(
      '/zones/$zoneId/settings/ssl',
      data: {'value': mode},
    );
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to update SSL settings: ${data['errors']}');
    }
  }
}
