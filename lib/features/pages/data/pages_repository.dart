import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/page.dart';
import '../../../core/network/api_client.dart';

final pagesRepositoryProvider = Provider<PagesRepository>((ref) {
  return PagesRepository(ref.watch(dioProvider));
});

class PagesRepository {
  final Dio _dio;
  String? _cachedAccountId;

  PagesRepository(this._dio);

  Future<String> _getAccountId() async {
    if (_cachedAccountId != null) return _cachedAccountId!;
    final response = await _dio.get('/accounts');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      if (results.isEmpty) throw Exception('No Cloudflare accounts found.');
      _cachedAccountId = results[0]['id'] as String;
      return _cachedAccountId!;
    } else {
      throw Exception('Failed to fetch accounts: ${data['errors']}');
    }
  }

  Future<List<CloudflarePage>> getPages() async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/pages/projects');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => CloudflarePage.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch Pages projects: ${data['errors']}');
    }
  }

  Future<List<PageDeployment>> getDeployments(String projectName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/pages/projects/$projectName/deployments');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => PageDeployment.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch deployments: ${data['errors']}');
    }
  }

  Future<List<PageDomain>> getDomains(String projectName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/pages/projects/$projectName/domains');
    final data = response.data;
    if (data['success'] == true) {
      final results = data['result'] as List<dynamic>;
      return results.map((e) => PageDomain.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch domains: ${data['errors']}');
    }
  }

  /// Add a custom domain to a Pages project
  Future<void> addDomain(String projectName, String domainName) async {
    final accountId = await _getAccountId();
    final response = await _dio.post(
      '/accounts/$accountId/pages/projects/$projectName/domains',
      data: {'name': domainName},
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to add domain: ${data['errors']}');
    }
  }

  /// Delete a custom domain from a Pages project
  Future<void> deleteDomain(String projectName, String domainName) async {
    final accountId = await _getAccountId();
    final response = await _dio.delete(
      '/accounts/$accountId/pages/projects/$projectName/domains/$domainName',
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to delete domain: ${data['errors']}');
    }
  }

  /// Get the full project (including deployment_configs with bindings)
  Future<CloudflarePage> getProject(String projectName) async {
    final accountId = await _getAccountId();
    final response = await _dio.get('/accounts/$accountId/pages/projects/$projectName');
    final data = response.data;
    if (data['success'] == true) {
      return CloudflarePage.fromJson(data['result'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch project: ${data['errors']}');
    }
  }

  /// Update project env vars / bindings by PATCHing deployment_configs
  Future<void> updateProjectBindings(String projectName, Map<String, dynamic> deploymentConfigs) async {
    final accountId = await _getAccountId();
    final response = await _dio.patch(
      '/accounts/$accountId/pages/projects/$projectName',
      data: {'deployment_configs': deploymentConfigs},
    );
    final data = response.data;
    if (data['success'] != true) {
      throw Exception('Failed to update bindings: ${data['errors']}');
    }
  }
}
