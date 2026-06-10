import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/page.dart';
import '../providers/pages_provider.dart';
import '../data/pages_repository.dart';

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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                page.subdomain,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              tooltip: 'Open site',
              onPressed: () async {
                final uri = Uri.tryParse('https://${page.subdomain}');
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failure':
        return Colors.red;
      case 'idle':
        return Colors.grey;
      default:
        return Colors.orange;
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
          return const Center(child: Text('No deployments found.'));
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
              _sectionHeader('Production', Colors.green),
              const SizedBox(height: 8),
              ...production.map((d) => _buildCard(context, d)),
              const SizedBox(height: 24),
            ],
            if (preview.isNotEmpty) ...[
              _sectionHeader('Preview', Colors.orange),
              const SizedBox(height: 8),
              ...preview.map((d) => _buildCard(context, d)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
    final color = _statusColor(d.status);
    final hasCommit = d.commitHash.isNotEmpty;
    String displayDate = d.createdOn;
    try {
      final dt = DateTime.parse(d.createdOn).toLocal();
      displayDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (hasCommit) ...[
                        const Icon(
                          Icons.call_split,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          d.branch,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          d.commitHash,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ] else
                        Text(
                          d.shortId,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
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
                    const SizedBox(height: 3),
                    Text(
                      d.commitMessage,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        displayDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (d.url.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
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

  Color _domainStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
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
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.language_outlined, color: Colors.grey, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No custom domains configured.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...domains.map((d) {
                final color = _domainStatusColor(d.status);
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
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
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Colors.blue,
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
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
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
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddDomainDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Custom Domain'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddDomainDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Domain'),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final domain = ctrl.text.trim();
              if (domain.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(pagesRepositoryProvider)
                    .addDomain(projectName, domain);
                ref.invalidate(pageDomainsProvider(projectName));
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Domain added! DNS verification may take a moment.',
                    ),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
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
        title: const Text('Remove Domain?'),
        content: Text('Remove "${domain.name}" from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
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

  (IconData, Color, String) _bindingStyle(String type) {
    switch (type) {
      case 'kv':
        return (Icons.storage, Colors.green, 'KV Namespace');
      case 'd1':
        return (Icons.dataset, Colors.blue, 'D1 Database');
      case 'r2':
        return (Icons.folder, Colors.purple, 'R2 Bucket');
      case 'service':
        return (Icons.hub, Colors.cyan, 'Service');
      case 'env':
        return (Icons.text_fields, Colors.orange, 'Env Var');
      case 'secret':
        return (Icons.lock, Colors.red, 'Secret');
      default:
        return (Icons.settings, Colors.grey, type);
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Bindings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...bindingEntries.map(
                (e) => _buildCard(context, ref, e, project),
              ),
              const SizedBox(height: 16),
            ],

            // ── Env Vars / Secrets section ──
            if (envEntries.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Environment Variables',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...envEntries.map((e) => _buildCard(context, ref, e, project)),
              const SizedBox(height: 16),
            ],

            if (hasAll)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.link_off, color: Colors.grey, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No bindings configured.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // ── Add buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showAddEnvVarDialog(context, ref, project),
                    icon: const Icon(Icons.text_fields, size: 16),
                    label: const Text('Env Var'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddKvDialog(context, ref, project),
                    icon: const Icon(Icons.storage, size: 16),
                    label: const Text('KV'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddD1Dialog(context, ref, project),
                    icon: const Icon(Icons.dataset, size: 16),
                    label: const Text('D1'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    _BindingEntry entry,
    CloudflarePage project,
  ) {
    final (icon, color, label) = _bindingStyle(entry.type);
    final displayDetail = entry.detail.length > 36
        ? '${entry.detail.substring(0, 16)}...'
        : entry.detail;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.isSecret ? '••••••••••••' : displayDetail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
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
        title: const Text('Delete Binding?'),
        content: Text('Are you sure you want to delete "${entry.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _showAddEnvVarDialog(
    BuildContext context,
    WidgetRef ref,
    CloudflarePage project,
  ) {
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    bool isSecret = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Environment Variable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Variable name',
                  hintText: 'e.g. API_KEY',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valCtrl,
                obscureText: isSecret,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: isSecret,
                    onChanged: (v) => setState(() => isSecret = v ?? false),
                  ),
                  const Text('Mark as Secret (encrypted)'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
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
                  updated[name] = {
                    'type': isSecret ? 'secret_text' : 'plain_text',
                    'value': val,
                  };
                  await ref.read(pagesRepositoryProvider).updateProjectBindings(
                    project.name,
                    {
                      'production': {'env_vars': updated},
                      'preview': {'env_vars': updated},
                    },
                  );
                  ref.invalidate(pageProjectProvider(project.name));
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Variable added.')),
                  );
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddKvDialog(
    BuildContext context,
    WidgetRef ref,
    CloudflarePage project,
  ) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add KV Namespace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Binding name',
                hintText: 'e.g. SITE_CONFIG',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'KV Namespace ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final id = idCtrl.text.trim();
              if (name.isEmpty || id.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = Map<String, dynamic>.from(project.kvNamespaces);
                updated[name] = {'namespace_id': id};
                await ref.read(pagesRepositoryProvider).updateProjectBindings(
                  project.name,
                  {
                    'production': {'kv_namespaces': updated},
                    'preview': {'kv_namespaces': updated},
                  },
                );
                ref.invalidate(pageProjectProvider(project.name));
                messenger.showSnackBar(
                  const SnackBar(content: Text('KV binding added.')),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddD1Dialog(
    BuildContext context,
    WidgetRef ref,
    CloudflarePage project,
  ) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add D1 Database'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Binding name',
                hintText: 'e.g. DB',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'D1 Database ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final id = idCtrl.text.trim();
              if (name.isEmpty || id.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = Map<String, dynamic>.from(project.d1Databases);
                updated[name] = {'id': id};
                await ref.read(pagesRepositoryProvider).updateProjectBindings(
                  project.name,
                  {
                    'production': {'d1_databases': updated},
                    'preview': {'d1_databases': updated},
                  },
                );
                ref.invalidate(pageProjectProvider(project.name));
                messenger.showSnackBar(
                  const SnackBar(content: Text('D1 binding added.')),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
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
