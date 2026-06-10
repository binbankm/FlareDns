import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/worker.dart';
import '../../../core/network/api_client.dart';

final workersRepositoryProvider = Provider<WorkersRepository>((ref) {
  return WorkersRepository(ref.watch(dioProvider));
});

class WorkersRepository {
  final Dio _dio;
  String? _cachedAccountId;

  WorkersRepository(this._dio);

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

  Future<List<CloudflareWorker>> getWorkers() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/scripts');
    final data = response.data;
    
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => CloudflareWorker.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch workers: ${data['errors']}');
    }
  }

  Future<List<WorkerBinding>> getBindings(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/scripts/$scriptName/bindings');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => WorkerBinding.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch bindings: ${data['errors']}');
    }
  }

  Future<List<WorkerSchedule>> getSchedules(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/scripts/$scriptName/schedules');
    final data = response.data;
    if (data['success'] == true) {
      final result = data['result'] as Map<String, dynamic>;
      final schedules = result['schedules'] as List<dynamic>? ?? [];
      return schedules.map((e) => WorkerSchedule.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch schedules: ${data['errors']}');
    }
  }

  Future<void> putSchedules(String scriptName, List<String> crons) async {
    final accountId = await _getAccountId();
    final response = await _dio.put(
      '/accounts/$accountId/workers/scripts/$scriptName/schedules',
      data: crons.map((c) => {'cron': c}).toList(),
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to update schedules: ${data['errors']}');
    }
  }

  Future<List<WorkerDeployment>> getDeployments(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/scripts/$scriptName/deployments');
    final data = response.data;
    if (data['success'] == true) {
      final result = data['result'] as Map<String, dynamic>;
      final deployments = result['deployments'] as List<dynamic>? ?? [];
      return deployments.map((e) => WorkerDeployment.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch deployments: ${data['errors']}');
    }
  }

  Future<List<WorkerDomain>> getDomains() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/domains');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => WorkerDomain.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch domains: ${data['errors']}');
    }
  }

  Future<void> addDomain(String scriptName, String hostname) async {
    final accountId = await _getAccountId();
    final response = await _dio.put(
      '/accounts/$accountId/workers/domains',
      data: {
        'environment': 'production',
        'hostname': hostname,
        'service': scriptName,
      },
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to add domain: ${data['errors']}');
    }
  }

  Future<void> deleteDomain(String domainId) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete('/accounts/$accountId/workers/domains/$domainId');
    // Note: Cloudflare API might return empty string on successful DELETE for domains
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete domain: ${response.statusCode}');
    }
  }


  Future<List<WorkerSecret>> getSecrets(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/workers/scripts/$scriptName/secrets');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => WorkerSecret.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch secrets: ${data['errors']}');
    }
  }

  Future<void> putSecret(String scriptName, String secretName, String secretValue) async {
    final accountId = await _getAccountId();
    final response = await _dio.put(
      '/accounts/$accountId/workers/scripts/$scriptName/secrets',
      data: {
        'name': secretName,
        'text': secretValue,
        'type': 'secret_text',
      },
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to add secret: ${data['errors']}');
    }
  }

  Future<void> deleteSecret(String scriptName, String secretName) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete('/accounts/$accountId/workers/scripts/$scriptName/secrets/$secretName');
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to delete secret: ${data['errors']}');
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

  Future<void> updateBindings(String scriptName, List<Map<String, dynamic>> bindings) async {
    final accountId = await _getAccountId();
    
    // 1. Fetch current code
    final code = await getWorkerContent(scriptName);

    // 2. Determine module type to construct metadata
    final isESModule = code.contains('export default') || code.contains('export const') || code.contains('export function');
    
    FormData formData;
    if (isESModule) {
      final metadata = {
        "main_module": "index.js",
        "bindings": bindings,
      };
      formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
        'index.js': MultipartFile.fromString(
          code,
          filename: 'index.js',
          contentType: DioMediaType('application', 'javascript+module'),
        ),
      });
    } else {
      final metadata = {
        "body_part": "script",
        "bindings": bindings,
      };
      formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
        'script': MultipartFile.fromString(
          code,
          filename: 'script.js',
          contentType: DioMediaType('application', 'javascript'),
        ),
      });
    }

    // 3. Put to deploy
    final response = await _dio.put(
      '/accounts/$accountId/workers/scripts/$scriptName',
      data: formData,
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to update bindings: ${data['errors']}');
    }
  }

  Future<void> deleteWorker(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete('/accounts/$accountId/workers/scripts/$scriptName');
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to delete worker: ${data['errors']}');
    }
  }

  Future<String> getWorkerContent(String scriptName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get(
      '/accounts/$accountId/workers/scripts/$scriptName/content/v2',
      options: Options(responseType: ResponseType.plain),
    );
    
    final contentType = response.headers.value('content-type');
    if (contentType != null && contentType.contains('multipart/form-data')) {
      final boundaryMatches = RegExp(r'boundary="?([^";]+)"?').allMatches(contentType);
      if (boundaryMatches.isNotEmpty) {
        final boundary = boundaryMatches.first.group(1)!;
        final parts = response.data.toString().split('--$boundary');
        for (var part in parts) {
          if (part.trim().isEmpty || part == '--') continue;
          final headBody = part.split('\r\n\r\n');
          if (headBody.length >= 2) {
            final headers = headBody[0];
            final body = headBody.sublist(1).join('\r\n\r\n').trim();
            if (headers.contains('application/javascript')) {
              // Extract just the javascript code
              return body;
            }
          }
        }
      }
    }
    // Fallback if not multipart or if extraction fails
    return response.data.toString();
  }

  Future<void> deployWorker(String scriptName, String code) async {
    final accountId = await _getAccountId();

    // 1. Fetch existing bindings to preserve them
    List<dynamic> existingBindings = [];
    try {
      final bRes = await _dio.get('/accounts/$accountId/workers/scripts/$scriptName/bindings');
      if (bRes.data['success'] == true) {
        existingBindings = bRes.data['result'] as List<dynamic>? ?? [];
      }
    } catch (_) {
      // Ignore if bindings fetch fails (e.g. new worker)
    }

    final isESModule = code.contains('export default') || code.contains('export const') || code.contains('export function');
    
    FormData formData;
    if (isESModule) {
      final metadata = {
        "main_module": "index.js",
        "bindings": existingBindings,
      };
      formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
        'index.js': MultipartFile.fromString(
          code,
          filename: 'index.js',
          contentType: DioMediaType('application', 'javascript+module'),
        ),
      });
    } else {
      final metadata = {
        "body_part": "script",
        "bindings": existingBindings,
      };
      formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
        'script': MultipartFile.fromString(
          code,
          filename: 'script.js',
          contentType: DioMediaType('application', 'javascript'),
        ),
      });
    }

    final response = await _dio.put(
      '/accounts/$accountId/workers/scripts/$scriptName',
      data: formData,
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to deploy worker: ${data['errors']}');
    }
  }
}
