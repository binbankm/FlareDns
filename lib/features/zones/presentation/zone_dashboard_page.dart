import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../providers/zones_provider.dart';

class ZoneDashboardPage extends ConsumerWidget {
  final String zoneId;
  final String zoneName;

  const ZoneDashboardPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(zoneName)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.dns,
            color: Theme.of(context).colorScheme.tertiary,
            title: l10n.zoneDashboardDns,
            subtitle: l10n.zoneDashboardDnsSubtitle,
            onTap: () => context.push(
              '/zone/$zoneId/dns?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.security_update_warning,
            color: Theme.of(context).colorScheme.error,
            title: l10n.zoneDashboardSecurity,
            subtitle: l10n.zoneDashboardSecuritySubtitle,
            onTap: () => context.push(
              '/zone/$zoneId/security?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.analytics,
            color: Theme.of(context).colorScheme.primary,
            title: l10n.zoneDashboardAnalytics,
            subtitle: l10n.zoneDashboardAnalyticsSubtitle,
            onTap: () => context.push(
              '/zone/$zoneId/analytics?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.speed,
            color: Theme.of(context).colorScheme.primaryContainer,
            title: l10n.zoneDashboardCaching,
            subtitle: l10n.zoneDashboardCachingSubtitle,
            onTap: () => context.push(
              '/zone/$zoneId/cache?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildSslCard(context, ref),
        ],
      ),
    );
  }

  Widget _buildSslCard(BuildContext context, WidgetRef ref) {
    final sslAsync = ref.watch(zoneSslCertificatesProvider(zoneId));
    final l10n = AppLocalizations.of(context);

    Widget trailingWidget = Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline);
    String subtitleText = l10n.zoneDashboardSslSubtitle;

    if (sslAsync.isLoading) {
      trailingWidget = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (sslAsync.hasError) {
      trailingWidget = Expanded(
        child: Text(
          'API Error: ${sslAsync.error}',
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 10),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else if (sslAsync.hasValue) {
      final certs = sslAsync.value!;
      if (certs.isNotEmpty) {
        final cert = certs.first;
        final status = cert['status'] ?? 'unknown';
        final type = cert['type'] ?? 'universal';
        subtitleText = l10n.zoneDashboardSslSubtitleWithCerts;

        final color = status == 'active' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary;

        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                type.toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
          ],
        );
      } else {
        trailingWidget = Text(
          l10n.zoneDashboardSslNoCerts,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/zone/$zoneId/ssl?name=${Uri.encodeComponent(zoneName)}',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SSL/TLS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
