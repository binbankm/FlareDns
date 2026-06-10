import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return SecurityRepository(ref.watch(dioProvider));
});

class SecurityRepository {
  final Dio _dio;

  SecurityRepository(this._dio);

  Future<String> getDevelopmentMode(String zoneId) async {
    final response = await _dio.get('/zones/$zoneId/settings/development_mode');
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to fetch development mode: ${data['errors']}');
    }
  }

  Future<String> setDevelopmentMode(String zoneId, String mode) async {
    final response = await _dio.patch(
      '/zones/$zoneId/settings/development_mode',
      data: {'value': mode},
    );
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to update development mode: ${data['errors']}');
    }
  }

  Future<String> getSecurityLevel(String zoneId) async {
    final response = await _dio.get('/zones/$zoneId/settings/security_level');
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to fetch security level: ${data['errors']}');
    }
  }

  Future<String> setSecurityLevel(String zoneId, String level) async {
    final response = await _dio.patch(
      '/zones/$zoneId/settings/security_level',
      data: {'value': level},
    );
    final data = response.data;
    if (data['success'] == true) {
      return data['result']['value'] as String;
    } else {
      throw Exception('Failed to update security level: ${data['errors']}');
    }
  }
}
