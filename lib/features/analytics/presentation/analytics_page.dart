import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  final String zoneId;
  final String zoneName;

  const AnalyticsPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
  });

  String _formatNumber(num value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}B';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  String _formatBytes(num bytes) {
    if (bytes >= 1099511627776) return '${(bytes / 1099511627776).toStringAsFixed(1)} TB';
    if (bytes >= 1073741824) return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider(zoneId));

    return Scaffold(
      appBar: AppBar(title: Text('Analytics: $zoneName')),
      body: analyticsAsync.when(
        data: (data) {
          final totals = data['totals'] as Map<String, dynamic>? ?? {};
          final requests = totals['requests'] as Map<String, dynamic>? ?? {};
          final bandwidth = totals['bandwidth'] as Map<String, dynamic>? ?? {};
          final pageviews = totals['pageviews'] as Map<String, dynamic>? ?? {};
          final uniques = totals['uniques'] as Map<String, dynamic>? ?? {};

          final reqAll = requests['all'] as num? ?? 0;
          final reqCached = requests['cached'] as num? ?? 0;
          final reqUncached = requests['uncached'] as num? ?? 0;

          final bwAll = bandwidth['all'] as num? ?? 0;
          final bwCached = bandwidth['cached'] as num? ?? 0;
          final bwUncached = bandwidth['uncached'] as num? ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(analyticsProvider(zoneId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Last 30 Days Summary', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Requests
                _buildStatCard(
                  context,
                  title: 'Total Requests',
                  value: _formatNumber(reqAll),
                  icon: Icons.sync_alt,
                  color: Colors.blue,
                  details: [
                    _DetailRow('Cached', _formatNumber(reqCached), Colors.green),
                    _DetailRow('Uncached', _formatNumber(reqUncached), Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Bandwidth
                _buildStatCard(
                  context,
                  title: 'Total Bandwidth',
                  value: _formatBytes(bwAll),
                  icon: Icons.data_usage,
                  color: Colors.purple,
                  details: [
                    _DetailRow('Cached', _formatBytes(bwCached), Colors.green),
                    _DetailRow('Uncached', _formatBytes(bwUncached), Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Unique Visitors
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniCard(
                        context,
                        title: 'Unique Visitors',
                        value: _formatNumber(uniques['all'] as num? ?? 0),
                        icon: Icons.people,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMiniCard(
                        context,
                        title: 'Page Views',
                        value: _formatNumber(pageviews['all'] as num? ?? 0),
                        icon: Icons.visibility,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Analytics data is not available for this zone or plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Details: $e', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(analyticsProvider(zoneId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required List<_DetailRow> details}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...details.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(d.label, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Text(d.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  final Color color;
  _DetailRow(this.label, this.value, this.color);
}
