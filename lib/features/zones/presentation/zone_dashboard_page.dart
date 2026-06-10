import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(zoneName)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.dns,
            color: Colors.orange,
            title: 'DNS',
            subtitle: 'Manage DNS records',
            onTap: () => context.push(
              '/zone/$zoneId/dns?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.security_update_warning,
            color: Colors.redAccent,
            title: 'Security',
            subtitle: 'Under attack mode & Dev mode',
            onTap: () => context.push(
              '/zone/$zoneId/security?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.analytics,
            color: Colors.blueAccent,
            title: 'Analytics',
            subtitle: 'Web traffic & usage metrics',
            onTap: () => context.push(
              '/zone/$zoneId/analytics?name=${Uri.encodeComponent(zoneName)}',
            ),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.speed,
            color: Colors.teal,
            title: 'Caching',
            subtitle: 'Purge cache & settings',
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

    Widget trailingWidget = const Icon(Icons.chevron_right, color: Colors.grey);
    String subtitleText = 'Manage encryption mode';

    if (sslAsync.isLoading) {
      trailingWidget = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (sslAsync.hasError) {
      trailingWidget = Expanded(
        child: Text(
          'API Error: ${sslAsync.error}',
          style: const TextStyle(color: Colors.red, fontSize: 10),
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
        subtitleText = 'Manage encryption mode & certificates';

        final color = status == 'active' ? Colors.green : Colors.orange;

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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        );
      } else {
        trailingWidget = const Text(
          'NO CERTS FOUND',
          style: TextStyle(
            color: Colors.grey,
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
                  color: Colors.purpleAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.purpleAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SSL/TLS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
