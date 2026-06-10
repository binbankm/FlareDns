import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
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

  String _formatTtl(BuildContext context, int ttl) {
    final l10n = AppLocalizations.of(context);
    if (ttl == 1) return l10n.dnsTtlAuto;
    if (ttl < 60) return l10n.dnsTtlSec(ttl);
    if (ttl < 3600) return l10n.dnsTtlMins(ttl ~/ 60);
    if (ttl < 86400) return l10n.dnsTtlHours(ttl ~/ 3600);
    return l10n.dnsTtlDays(ttl ~/ 86400);
  }

  @override
  Widget build(BuildContext context) {
    final dnsRecordsAsyncValue = ref.watch(dnsRecordsProvider(widget.zoneId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dnsTitle(widget.zoneName)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
                  decoration: InputDecoration(
                    hintText: l10n.dnsSearch,
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
                  return Center(child: Text(l10n.dnsEmpty));
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
                  return Center(
                    child: Text(l10n.dnsNoMatch),
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
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    record.content,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.outline,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _formatTtl(context, record.ttl),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          if (record.priority != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                l10n.dnsPriority(record.priority!),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
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
                                                                AppLocalizations.of(context).commonError(e.toString()),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                },
                                              ),
                                            ),
                                          SizedBox(width: 4),
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Theme.of(context).colorScheme.error,
                                                size: 18,
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text(
                                                      l10n.dnsDeleteTitle,
                                                    ),
                                                    content: Text(
                                                      l10n.dnsDeleteContent(record.name),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            context.pop(false),
                                                        child: Text(
                                                          l10n.commonCancel,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            context.pop(true),
                                                        child: Text(
                                                          l10n.commonDelete,
                                                          style: TextStyle(
                                                            color: Theme.of(context).colorScheme.error,
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
                                                            AppLocalizations.of(context).commonError(e.toString()),
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
                      onPressed: () =>
                          ref.invalidate(dnsRecordsProvider(widget.zoneId)),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          context.push('/zone/${widget.zoneId}/dns/form');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
