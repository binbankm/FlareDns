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
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  String _formatBytes(num bytes) {
    if (bytes >= 1099511627776) {
      return '${(bytes / 1099511627776).toStringAsFixed(1)} TB';
    }
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
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
                Text(
                  'Last 30 Days Summary',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Requests
                _buildStatCard(
                  context,
                  title: 'Total Requests',
                  value: _formatNumber(reqAll),
                  icon: Icons.sync_alt,
                  color: Theme.of(context).colorScheme.primary,
                  details: [
                    _DetailRow(
                      'Cached',
                      _formatNumber(reqCached),
                      Theme.of(context).colorScheme.primary,
                    ),
                    _DetailRow(
                      'Uncached',
                      _formatNumber(reqUncached),
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Bandwidth
                _buildStatCard(
                  context,
                  title: 'Total Bandwidth',
                  value: _formatBytes(bwAll),
                  icon: Icons.data_usage,
                  color: Theme.of(context).colorScheme.secondary,
                  details: [
                    _DetailRow('Cached', _formatBytes(bwCached), Theme.of(context).colorScheme.primary),
                    _DetailRow(
                      'Uncached',
                      _formatBytes(bwUncached),
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Unique Visitors
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniCard(
                        context,
                        title: 'Unique Visitors',
                        value: _formatNumber(uniques['all'] as num? ?? 0),
                        icon: Icons.people,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildMiniCard(
                        context,
                        title: 'Page Views',
                        value: _formatNumber(pageviews['all'] as num? ?? 0),
                        icon: Icons.visibility,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                SizedBox(height: 16),
                Text(
                  'Analytics data is not available for this zone or plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Details: $e',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(analyticsProvider(zoneId)),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<_DetailRow> details,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            const Divider(),
            SizedBox(height: 8),
            ...details.map(
              (d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: d.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          d.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      d.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
