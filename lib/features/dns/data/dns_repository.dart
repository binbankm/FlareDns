import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/dns_record.dart';

final dnsRepositoryProvider = Provider<DnsRepository>((ref) {
  return DnsRepository(ref.watch(dioProvider));
});

class DnsRepository {
  final Dio _dio;

  DnsRepository(this._dio);

  Future<List<DnsRecord>> getDnsRecords(String zoneId) async {
    final List<DnsRecord> allRecords = [];
    int page = 1;
    int totalPages = 1;

    do {
      final response = await _dio.get(
        '/zones/$zoneId/dns_records',
        queryParameters: {'page': page, 'per_page': 50},
      );
      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> result = data['result'];
        allRecords.addAll(result.map((json) => DnsRecord.fromJson(json)));

        final resultInfo = data['result_info'];
        if (resultInfo != null) {
          totalPages = resultInfo['total_pages'] as int? ?? 1;
        } else {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to fetch DNS records: ${data['errors']}');
      }
    } while (page <= totalPages);

    return allRecords;
  }

  Future<DnsRecord> createDnsRecord(String zoneId, DnsRecord record) async {
    final response = await _dio.post(
      '/zones/$zoneId/dns_records',
      data: record.toJson(),
    );
    final data = response.data;
    if (data['success'] == true) {
      return DnsRecord.fromJson(data['result']);
    } else {
      throw Exception('Failed to create DNS record: ${data['errors']}');
    }
  }

  Future<DnsRecord> updateDnsRecord(String zoneId, DnsRecord record) async {
    final response = await _dio.put(
      '/zones/$zoneId/dns_records/${record.id}',
      data: record.toJson(),
    );
    final data = response.data;
    if (data['success'] == true) {
      return DnsRecord.fromJson(data['result']);
    } else {
      throw Exception('Failed to update DNS record: ${data['errors']}');
    }
  }

  Future<void> deleteDnsRecord(String zoneId, String recordId) async {
    final response = await _dio.delete('/zones/$zoneId/dns_records/$recordId');
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to delete DNS record: ${data['errors']}');
    }
  }

  Future<DnsRecord> patchDnsRecordProxied(
    String zoneId,
    DnsRecord record,
    bool proxied,
  ) async {
    final response = await _dio.patch(
      '/zones/$zoneId/dns_records/${record.id}',
      data: {'proxied': proxied},
    );
    final data = response.data;
    if (data['success'] == true) {
      return DnsRecord.fromJson(data['result']);
    } else {
      throw Exception('Failed to patch DNS record: ${data['errors']}');
    }
  }
}
