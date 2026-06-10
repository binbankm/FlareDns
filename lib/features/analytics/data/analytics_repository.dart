import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(dioProvider));
});

class AnalyticsRepository {
  final Dio _dio;

  AnalyticsRepository(this._dio);

  Future<Map<String, dynamic>> getDashboardMetrics(String zoneId) async {
    // Cloudflare GraphQL API
    final String dateGeq = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')[0];

    final query =
        '''
      query {
        viewer {
          zones(filter: { zoneTag: "$zoneId" }) {
            httpRequests1dGroups(limit: 30, filter: { date_geq: "$dateGeq" }) {
              sum {
                requests
                bytes
                pageViews
                cachedRequests
                cachedBytes
              }
            }
          }
        }
      }
    ''';

    // The auth headers are already injected by ApiClient (X-Auth-Email, X-Auth-Key)
    // We just need to POST to /graphql. However, ApiClient base URL is usually /client/v4.
    // The GraphQL endpoint is /graphql. So we need to use a relative path if possible,
    // or absolute if base url is /client/v4.
    // Assuming base URL is 'https://api.cloudflare.com/client/v4'
    final response = await _dio.post('/graphql', data: {'query': query});

    final data = response.data;
    if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
      throw Exception('GraphQL Error: ${data['errors'][0]['message']}');
    }

    final viewer = data['data']?['viewer'];
    if (viewer == null) throw Exception('No data returned');

    final zones = viewer['zones'] as List<dynamic>? ?? [];
    if (zones.isEmpty) throw Exception('Zone not found in analytics');

    final groups = zones[0]['httpRequests1dGroups'] as List<dynamic>? ?? [];

    num totalReqs = 0;
    num totalBytes = 0;
    num totalPageViews = 0;
    num totalCachedReqs = 0;
    num totalCachedBytes = 0;

    for (var group in groups) {
      final sum = group['sum'] ?? {};
      totalReqs += sum['requests'] ?? 0;
      totalBytes += sum['bytes'] ?? 0;
      totalPageViews += sum['pageViews'] ?? 0;
      totalCachedReqs += sum['cachedRequests'] ?? 0;
      totalCachedBytes += sum['cachedBytes'] ?? 0;
    }

    return {
      'totals': {
        'requests': {
          'all': totalReqs,
          'cached': totalCachedReqs,
          'uncached': totalReqs - totalCachedReqs,
        },
        'bandwidth': {
          'all': totalBytes,
          'cached': totalCachedBytes,
          'uncached': totalBytes - totalCachedBytes,
        },
        'pageviews': {'all': totalPageViews},
        'uniques': {
          'all':
              0, // uniques is not easily available in the free httpRequests1dGroups
        },
      },
    };
  }
}
