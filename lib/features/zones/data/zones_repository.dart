import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/zone.dart';

final zonesRepositoryProvider = Provider<ZonesRepository>((ref) {
  return ZonesRepository(ref.watch(dioProvider));
});

class ZonesRepository {
  final Dio _dio;

  ZonesRepository(this._dio);

  Future<List<Zone>> getZones() async {
    final List<Zone> allZones = [];
    int page = 1;
    int totalPages = 1;

    do {
      final response = await _dio.get('/zones', queryParameters: {'page': page, 'per_page': 50});
      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> result = data['result'];
        allZones.addAll(result.map((json) => Zone.fromJson(json)));
        
        final resultInfo = data['result_info'];
        if (resultInfo != null) {
          totalPages = resultInfo['total_pages'] as int? ?? 1;
        } else {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to fetch zones: ${data['errors']}');
      }
    } while (page <= totalPages);

    return allZones;
  }

  Future<List<dynamic>> getSslCertificates(String zoneId) async {
    final response = await _dio.get('/zones/$zoneId/ssl/certificate_packs');
    final data = response.data;
    if (data['success'] == true) {
      return data['result'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch SSL certificates: ${data['errors']}');
    }
  }
}
