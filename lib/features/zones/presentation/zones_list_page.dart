import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/zones_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/theme_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domains'),
        actions: [
          IconButton(
            icon: Icon(ref.watch(themeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(zonesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search domains...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: zonesAsyncValue.when(
              data: (zones) {
                if (zones.isEmpty) {
                  return const Center(child: Text('No zones found.'));
                }

                final filtered = zones.where((z) {
                  return z.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No domains match your search.'));
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final zone = filtered[index];
                        final isActive = zone.status == 'active';
                        final statusColor = isActive ? Colors.green : Colors.red;
                        final colorScheme = Theme.of(context).colorScheme;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: colorScheme.outlineVariant, width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.push('/zone/${zone.id}?name=${Uri.encodeComponent(zone.name)}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(isActive ? Icons.public : Icons.public_off, color: statusColor, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                                          ),
                                          if (zone.planName != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(zone.planName!, style: TextStyle(fontSize: 11, color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ]),
                                        const SizedBox(height: 5),
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(zone.status.toUpperCase(), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                                          ),
                                        ]),
                                        if (zone.nameServers.isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          ...zone.nameServers.take(2).map((ns) => Row(children: [
                                            const Icon(Icons.dns_outlined, size: 11, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(child: Text(ns, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                          ])),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(zonesProvider),
                      child: const Text('Retry'),
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
