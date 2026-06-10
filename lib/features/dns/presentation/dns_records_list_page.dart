import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dns_provider.dart';

class DnsRecordsListPage extends ConsumerStatefulWidget {
  final String zoneId;
  final String zoneName;

  const DnsRecordsListPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  ConsumerState<DnsRecordsListPage> createState() => _DnsRecordsListPageState();
}

class _DnsRecordsListPageState extends ConsumerState<DnsRecordsListPage> {
  String _searchQuery = '';

  String _formatTtl(int ttl) {
    if (ttl == 1) return 'Auto';
    if (ttl < 60) return '$ttl sec';
    if (ttl < 3600) return '${ttl ~/ 60} mins';
    if (ttl < 86400) return '${ttl ~/ 3600} hours';
    return '${ttl ~/ 86400} days';
  }

  @override
  Widget build(BuildContext context) {
    final dnsRecordsAsyncValue = ref.watch(dnsRecordsProvider(widget.zoneId));

    return Scaffold(
      appBar: AppBar(
        title: Text('DNS: ${widget.zoneName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dnsRecordsProvider(widget.zoneId));
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
                  decoration: const InputDecoration(
                    hintText: 'Search DNS records...',
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
            child: dnsRecordsAsyncValue.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No DNS records found.'));
                }

                final filtered = records.where((r) {
                  return r.name.toLowerCase().contains(_searchQuery) ||
                      r.content.toLowerCase().contains(_searchQuery);
                }).toList();

                // Sort by Type then Name
                filtered.sort((a, b) {
                  final typeComp = a.type.compareTo(b.type);
                  if (typeComp != 0) return typeComp;
                  return a.name.compareTo(b.name);
                });

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No records match your search.'),
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
                        final record = filtered[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              context.push(
                                '/zone/${widget.zoneId}/dns/form',
                                extra: record,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          record.type,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    record.content,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _formatTtl(record.ttl),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (record.priority != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Pri: ${record.priority}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          // Proxied Toggle (Small)
                                          if ([
                                            'A',
                                            'AAAA',
                                            'CNAME',
                                          ].contains(record.type))
                                            SizedBox(
                                              height: 20,
                                              child: Switch(
                                                value: record.proxied,
                                                activeThumbColor: Colors.orange,
                                                onChanged: (val) {
                                                  ref
                                                      .read(dnsMutationProvider)
                                                      .toggleProxied(
                                                        widget.zoneId,
                                                        record,
                                                        val,
                                                      )
                                                      .catchError((e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Error: $e',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                },
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      'Delete Record',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete ${record.name}?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            context.pop(false),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            context.pop(true),
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true &&
                                                    context.mounted) {
                                                  try {
                                                    await ref
                                                        .read(
                                                          dnsMutationProvider,
                                                        )
                                                        .deleteRecord(
                                                          widget.zoneId,
                                                          record.id,
                                                        );
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Error: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(dnsRecordsProvider(widget.zoneId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/zone/${widget.zoneId}/dns/form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
