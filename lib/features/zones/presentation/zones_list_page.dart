import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../providers/zones_provider.dart';

class ZonesListPage extends ConsumerStatefulWidget {
  const ZonesListPage({super.key});

  @override
  ConsumerState<ZonesListPage> createState() => _ZonesListPageState();
}

class _ZonesListPageState extends ConsumerState<ZonesListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final zonesAsyncValue = ref.watch(zonesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zonesTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(zonesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.zonesSearch,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: zonesAsyncValue.when(
              data: (zones) {
                if (zones.isEmpty) {
                  return Center(child: Text(l10n.zonesEmpty));
                }

                final filtered = zones.where((z) {
                  return z.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(l10n.zonesNoMatch),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final zone = filtered[index];
                        final isActive = zone.status == 'active';
                        final statusColor = isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.red;
                        final colorScheme = Theme.of(context).colorScheme;

                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.push(
                              '/zone/${zone.id}?name=${Uri.encodeComponent(zone.name)}',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isActive
                                          ? Icons.public
                                          : Icons.public_off,
                                      color: statusColor,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                zone.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (zone.planName != null) ...[
                                              SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme
                                                      .primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  zone.planName!,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: colorScheme
                                                        .onPrimaryContainer,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(
                                                  alpha: 0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                zone.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (zone.nameServers.isNotEmpty) ...[
                                          SizedBox(height: 5),
                                          ...zone.nameServers
                                              .take(2)
                                              .map(
                                                (ns) => Row(
                                                  children: [
                                                    Icon(
                                                      Icons.dns_outlined,
                                                      size: 11,
                                                      color: Theme.of(context).colorScheme.outline,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        ns,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Theme.of(context).colorScheme.outline,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colorScheme.outline,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context).commonError(error.toString()), textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(zonesProvider),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
