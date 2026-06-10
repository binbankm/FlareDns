import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/zones/presentation/zone_dashboard_page.dart';
import '../../features/dns/domain/dns_record.dart';
import '../../features/dns/presentation/dns_records_list_page.dart';
import '../../features/dns/presentation/dns_record_form_page.dart';
import '../../features/cache/presentation/cache_page.dart';
import '../../features/ssl/presentation/ssl_page.dart';
import '../../features/security/presentation/security_page.dart';
import '../../features/analytics/presentation/analytics_page.dart';
import '../../features/workers/presentation/worker_dashboard_page.dart';
import '../../features/workers/domain/worker.dart';
import '../../features/pages/presentation/page_dashboard_page.dart';
import '../../features/pages/domain/page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) return null;

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const AuthPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/zone/:zoneId',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return ZoneDashboardPage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/dns',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return DnsRecordsListPage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/dns/form',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final existingRecord = state.extra as DnsRecord?;
          return DnsRecordFormPage(
            zoneId: zoneId,
            existingRecord: existingRecord,
          );
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/cache',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return CachePage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/ssl',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return SslPage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/security',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return SecurityPage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/zone/:zoneId/analytics',
        builder: (context, state) {
          final zoneId = state.pathParameters['zoneId']!;
          final zoneName = state.uri.queryParameters['name'] ?? 'Unknown Zone';
          return AnalyticsPage(zoneId: zoneId, zoneName: zoneName);
        },
      ),
      GoRoute(
        path: '/worker/:workerId',
        builder: (context, state) {
          final worker = state.extra as CloudflareWorker;
          final initialTabStr = state.uri.queryParameters['initialTab'];
          final initialTab = initialTabStr != null
              ? int.tryParse(initialTabStr) ?? 0
              : 0;
          return WorkerDashboardPage(
            worker: worker,
            initialTabIndex: initialTab,
          );
        },
      ),
      GoRoute(
        path: '/page/:projectName',
        builder: (context, state) {
          final page = state.extra as CloudflarePage;
          return PageDashboardPage(page: page);
        },
      ),
    ],
  );
});
