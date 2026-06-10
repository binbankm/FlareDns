import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ZoneDashboardPage extends StatelessWidget {
  final String zoneId;
  final String zoneName;

  const ZoneDashboardPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(zoneName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.dns,
            title: 'DNS',
            subtitle: 'Manage DNS records',
            onTap: () => context.push('/zone/$zoneId/dns?name=${Uri.encodeComponent(zoneName)}'),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.security_update_warning,
            title: 'Security',
            subtitle: 'Under attack mode & Dev mode',
            onTap: () => context.push('/zone/$zoneId/security?name=${Uri.encodeComponent(zoneName)}'),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'Web traffic & usage metrics',
            onTap: () => context.push('/zone/$zoneId/analytics?name=${Uri.encodeComponent(zoneName)}'),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.speed,
            title: 'Caching',
            subtitle: 'Purge cache & settings',
            onTap: () => context.push('/zone/$zoneId/cache?name=${Uri.encodeComponent(zoneName)}'),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.security,
            title: 'SSL/TLS',
            subtitle: 'Manage encryption mode',
            onTap: () => context.push('/zone/$zoneId/ssl?name=${Uri.encodeComponent(zoneName)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
