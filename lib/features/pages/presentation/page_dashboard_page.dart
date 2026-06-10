import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/page.dart';
import '../providers/pages_provider.dart';
import '../data/pages_repository.dart';
import '../../zones/data/zones_repository.dart';
import '../../dns/data/dns_repository.dart';
import '../../dns/domain/dns_record.dart';

class PageDashboardPage extends ConsumerWidget {
  final CloudflarePage page;

  const PageDashboardPage({super.key, required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                page.subdomain,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.open_in_new, size: 20),
              tooltip: 'Open site',
              onPressed: () async {
                final uri = Uri.tryParse('https://${page.subdomain}');
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(pageDeploymentsProvider(page.name));
                ref.invalidate(pageDomainsProvider(page.name));
                ref.invalidate(pageProjectProvider(page.name));
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.rocket_launch), text: 'Deployments'),
              Tab(icon: Icon(Icons.language), text: 'Domains'),
              Tab(icon: Icon(Icons.link), text: 'Bindings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DeploymentsTab(projectName: page.name),
            _DomainsTab(projectName: page.name),
            _BindingsTab(page: page),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DEPLOYMENTS TAB
// ─────────────────────────────────────────────────────────
class _DeploymentsTab extends ConsumerWidget {
  final String projectName;
  const _DeploymentsTab({required this.projectName});

  Color _statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'success':
        return colorScheme.primary;
      case 'failure':
        return colorScheme.error;
      case 'idle':
        return colorScheme.outline;
      default:
        return colorScheme.tertiary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'failure':
        return Icons.error;
      case 'idle':
        return Icons.circle_outlined;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deploymentsAsync = ref.watch(pageDeploymentsProvider(projectName));

    return deploymentsAsync.when(
      data: (deployments) {
        if (deployments.isEmpty) {
          return Center(child: Text('No deployments found.'));
        }

        final production = deployments
            .where((d) => d.environment == 'production')
            .toList();
        final preview = deployments
            .where((d) => d.environment == 'preview')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (production.isNotEmpty) ...[
              _sectionHeader('Production', Theme.of(context).colorScheme.primary),
              SizedBox(height: 8),
              ...production.map((d) => _buildCard(context, d)),
              SizedBox(height: 24),
            ],
            if (preview.isNotEmpty) ...[
              _sectionHeader('Preview', Theme.of(context).colorScheme.tertiary),
              SizedBox(height: 8),
              ...preview.map((d) => _buildCard(context, d)),
            ],
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, PageDeployment d) {
    final color = _statusColor(context, d.status);
    final hasCommit = d.commitHash.isNotEmpty;
    String displayDate = d.createdOn;
    try {
      final dt = DateTime.parse(d.createdOn).toLocal();
      displayDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(d.status), color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (hasCommit) ...[
                        Icon(
                          Icons.call_split,
                          size: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            d.branch,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          d.commitHash,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ] else
                        Text(
                          d.shortId,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasCommit && d.commitMessage.isNotEmpty) ...[
                    SizedBox(height: 3),
                    Text(
                      d.commitMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(width: 3),
                      Text(
                        displayDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (d.url.isNotEmpty)
              IconButton(
                icon: Icon(Icons.open_in_new, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  final uri = Uri.tryParse(d.url);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DOMAINS TAB
// ─────────────────────────────────────────────────────────
class _DomainsTab extends ConsumerWidget {
  final String projectName;
  const _DomainsTab({required this.projectName});

  Color _domainStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'active':
        return colorScheme.primary;
      case 'blocked':
        return colorScheme.error;
      case 'pending':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainsAsync = ref.watch(pageDomainsProvider(projectName));

    return domainsAsync.when(
      data: (domains) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (domains.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language_outlined, color: Theme.of(context).colorScheme.outline, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No custom domains configured.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...domains.map((d) {
                final color = _domainStatusColor(context, d.status);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.language, color: color, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  d.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () async {
                            final uri = Uri.tryParse('https://${d.name}');
                            if (uri != null) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _confirmDelete(context, ref, d),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddDomainDialog(context, ref),
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Custom Domain'),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddDomainDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Custom Domain'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Domain name',
            hintText: 'e.g. mail.example.com',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final domain = ctrl.text.trim();
              if (domain.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                // 1. Add domain to Pages project
                await ref
                    .read(pagesRepositoryProvider)
                    .addDomain(projectName, domain);
                ref.invalidate(pageDomainsProvider(projectName));

                // 2. Attempt to Auto-configure DNS
                bool autoDnsSuccess = false;
                try {
                  final zones = await ref
                      .read(zonesRepositoryProvider)
                      .getZones();

                  // Find the zone that matches the domain suffix
                  dynamic matchedZone;
                  for (final z in zones) {
                    if (domain == z.name || domain.endsWith('.${z.name}')) {
                      if (matchedZone == null ||
                          z.name.length > matchedZone.name.length) {
                        matchedZone = z;
                      }
                    }
                  }

                  if (matchedZone != null) {
                    final target = '$projectName.pages.dev';
                    await ref
                        .read(dnsRepositoryProvider)
                        .createDnsRecord(
                          matchedZone.id,
                          DnsRecord(
                            id: '',
                            name: domain,
                            type: 'CNAME',
                            content: target,
                            proxied: true,
                            ttl: 1, // Auto
                          ),
                        );
                    autoDnsSuccess = true;
                  }
                } catch (dnsError) {
                  debugPrint('Auto DNS failed: $dnsError');
                }

                if (autoDnsSuccess) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Domain added and CNAME auto-configured!'),
                      
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Domain added! Please add the CNAME manually.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PageDomain domain,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Domain?'),
        content: Text('Remove "${domain.name}" from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Remove',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(pagesRepositoryProvider)
          .deleteDomain(projectName, domain.name);
      ref.invalidate(pageDomainsProvider(projectName));
      messenger.showSnackBar(const SnackBar(content: Text('Domain removed.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ─────────────────────────────────────────────────────────
// BINDINGS TAB
// ─────────────────────────────────────────────────────────
class _BindingsTab extends ConsumerWidget {
  final CloudflarePage page;
  const _BindingsTab({required this.page});

  (IconData, Color, String) _bindingStyle(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case 'kv':
        return (Icons.storage, colorScheme.primary, 'KV Namespace');
      case 'd1':
        return (Icons.dataset, colorScheme.secondary, 'D1 Database');
      case 'r2':
        return (Icons.folder, colorScheme.tertiary, 'R2 Bucket');
      case 'service':
        return (Icons.hub, colorScheme.primary, 'Service');
      case 'env':
        return (Icons.text_fields, colorScheme.tertiary, 'Env Var');
      case 'secret':
        return (Icons.lock, colorScheme.error, 'Secret');
      default:
        return (Icons.settings, colorScheme.outline, type);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(pageProjectProvider(page.name));

    return projectAsync.when(
      data: (project) {
        // Env vars & secrets
        final List<_BindingEntry> envEntries = [];
        project.productionEnvVars.forEach((name, val) {
          final v = val as Map<String, dynamic>?;
          final isSecret = v?['type'] == 'secret_text';
          envEntries.add(
            _BindingEntry(
              name: name,
              type: isSecret ? 'secret' : 'env',
              detail: isSecret ? '' : (v?['value'] as String? ?? ''),
              isSecret: isSecret,
            ),
          );
        });

        // Resource bindings
        final List<_BindingEntry> bindingEntries = [];
        project.kvNamespaces.forEach((name, val) {
          final v = val as Map<String, dynamic>?;
          bindingEntries.add(
            _BindingEntry(
              name: name,
              type: 'kv',
              detail: v?['namespace_id'] as String? ?? '',
            ),
          );
        });
        project.d1Databases.forEach((name, val) {
          final v = val as Map<String, dynamic>?;
          bindingEntries.add(
            _BindingEntry(
              name: name,
              type: 'd1',
              detail: v?['id'] as String? ?? '',
            ),
          );
        });
        project.r2Buckets.forEach((name, val) {
          final v = val as Map<String, dynamic>?;
          bindingEntries.add(
            _BindingEntry(
              name: name,
              type: 'r2',
              detail: v?['name'] as String? ?? '',
            ),
          );
        });
        project.serviceBindings.forEach((name, val) {
          final v = val as Map<String, dynamic>?;
          bindingEntries.add(
            _BindingEntry(
              name: name,
              type: 'service',
              detail: v?['service'] as String? ?? '',
            ),
          );
        });

        final hasAll = bindingEntries.isEmpty && envEntries.isEmpty;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Bindings section ──
            if (bindingEntries.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Bindings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              ...bindingEntries.map(
                (e) => _buildCard(context, ref, e, project),
              ),
              SizedBox(height: 16),
            ],

            // ── Env Vars / Secrets section ──
            if (envEntries.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Environment Variables',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              ...envEntries.map((e) => _buildCard(context, ref, e, project)),
              SizedBox(height: 16),
            ],

            if (hasAll)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_off, color: Theme.of(context).colorScheme.outline, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No bindings configured.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Add buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AddPageBindingDialog(project: project),
                    ),
                    icon: Icon(Icons.add_link, size: 18),
                    label: Text('Add Binding'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showAddPageSecretDialog(context, ref, project),
                    icon: Icon(Icons.lock_outline, size: 18),
                    label: Text('Add Secret'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddPageSecretDialog(
    BuildContext context,
    WidgetRef ref,
    CloudflarePage project,
  ) {
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Secret Name (e.g. API_KEY)',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: valCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Secret Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final val = valCtrl.text;
              if (name.isEmpty || val.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = Map<String, dynamic>.from(
                  project.productionEnvVars,
                );
                updated[name] = {'type': 'secret_text', 'value': val};
                await ref.read(pagesRepositoryProvider).updateProjectBindings(
                  project.name,
                  {
                    'production': {'env_vars': updated},
                    'preview': {'env_vars': updated},
                  },
                );
                ref.invalidate(pageProjectProvider(project.name));
                messenger.showSnackBar(
                  const SnackBar(content: Text('Secret added.')),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    _BindingEntry entry,
    CloudflarePage project,
  ) {
    final (icon, color, label) = _bindingStyle(context, entry.type);
    final displayDetail = entry.detail.length > 36
        ? '${entry.detail.substring(0, 16)}...'
        : entry.detail;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (displayDetail.isNotEmpty) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.isSecret ? '••••••••••••' : displayDetail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => _deleteBinding(context, ref, entry, project),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBinding(
    BuildContext context,
    WidgetRef ref,
    _BindingEntry entry,
    CloudflarePage project,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Binding?'),
        content: Text('Are you sure you want to delete "${entry.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      Map<String, dynamic> updatedConfig = {};
      if (entry.type == 'env' || entry.type == 'secret') {
        final updated = Map<String, dynamic>.from(project.productionEnvVars)
          ..remove(entry.name);
        updatedConfig = {
          'production': {'env_vars': updated},
          'preview': {'env_vars': updated},
        };
      } else if (entry.type == 'kv') {
        final updated = Map<String, dynamic>.from(project.kvNamespaces)
          ..remove(entry.name);
        updatedConfig = {
          'production': {'kv_namespaces': updated},
          'preview': {'kv_namespaces': updated},
        };
      } else if (entry.type == 'd1') {
        final updated = Map<String, dynamic>.from(project.d1Databases)
          ..remove(entry.name);
        updatedConfig = {
          'production': {'d1_databases': updated},
          'preview': {'d1_databases': updated},
        };
      } else if (entry.type == 'r2') {
        final updated = Map<String, dynamic>.from(project.r2Buckets)
          ..remove(entry.name);
        updatedConfig = {
          'production': {'r2_buckets': updated},
          'preview': {'r2_buckets': updated},
        };
      }
      await ref
          .read(pagesRepositoryProvider)
          .updateProjectBindings(project.name, updatedConfig);
      ref.invalidate(pageProjectProvider(project.name));
      messenger.showSnackBar(const SnackBar(content: Text('Binding deleted.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class AddPageBindingDialog extends ConsumerStatefulWidget {
  final CloudflarePage project;

  const AddPageBindingDialog({super.key, required this.project});

  @override
  ConsumerState<AddPageBindingDialog> createState() =>
      _AddPageBindingDialogState();
}

class _AddPageBindingDialogState extends ConsumerState<AddPageBindingDialog> {
  String _selectedType = 'plain_text';
  final _nameCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Binding'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Binding Type'),
              items: const [
                DropdownMenuItem(
                  value: 'plain_text',
                  child: Text('Plain Text (Env Var)'),
                ),
                DropdownMenuItem(
                  value: 'kv_namespace',
                  child: Text('KV Namespace'),
                ),
                DropdownMenuItem(value: 'd1', child: Text('D1 Database')),
              ],
              onChanged: (val) {
                setState(() => _selectedType = val!);
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Binding Name (e.g. DB, MY_KV, API_URL)',
              ),
            ),
            SizedBox(height: 8),
            if (_selectedType == 'plain_text')
              TextField(
                controller: _detailCtrl,
                decoration: const InputDecoration(labelText: 'Value'),
              )
            else if (_selectedType == 'kv_namespace')
              TextField(
                controller: _detailCtrl,
                decoration: const InputDecoration(labelText: 'KV Namespace ID'),
              )
            else if (_selectedType == 'd1')
              TextField(
                controller: _detailCtrl,
                decoration: const InputDecoration(labelText: 'D1 Database ID'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            final detail = _detailCtrl.text.trim();
            if (name.isEmpty || detail.isEmpty) return;
            Navigator.pop(context);
            final messenger = ScaffoldMessenger.of(context);
            try {
              Map<String, dynamic> updatedConfig = {};

              if (_selectedType == 'plain_text') {
                final updated = Map<String, dynamic>.from(
                  widget.project.productionEnvVars,
                );
                updated[name] = {'type': 'plain_text', 'value': detail};
                updatedConfig = {'env_vars': updated};
              } else if (_selectedType == 'kv_namespace') {
                final updated = Map<String, dynamic>.from(
                  widget.project.kvNamespaces,
                );
                updated[name] = {'namespace_id': detail};
                updatedConfig = {'kv_namespaces': updated};
              } else if (_selectedType == 'd1') {
                final updated = Map<String, dynamic>.from(
                  widget.project.d1Databases,
                );
                updated[name] = {'id': detail};
                updatedConfig = {'d1_databases': updated};
              }

              await ref.read(pagesRepositoryProvider).updateProjectBindings(
                widget.project.name,
                {'production': updatedConfig, 'preview': updatedConfig},
              );
              ref.invalidate(pageProjectProvider(widget.project.name));
              messenger.showSnackBar(
                const SnackBar(content: Text('Binding added.')),
              );
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class _BindingEntry {
  final String name;
  final String type;
  final String detail;
  final bool isSecret;

  _BindingEntry({
    required this.name,
    required this.type,
    required this.detail,
    this.isSecret = false,
  });
}
