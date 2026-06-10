import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/worker.dart';
import '../providers/workers_provider.dart';
import '../data/workers_repository.dart';

class WorkerDashboardPage extends ConsumerStatefulWidget {
  final CloudflareWorker worker;
  final int initialTabIndex;

  const WorkerDashboardPage({
    super.key,
    required this.worker,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<WorkerDashboardPage> createState() =>
      _WorkerDashboardPageState();
}

class _WorkerDashboardPageState extends ConsumerState<WorkerDashboardPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isDeploying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _deployCode(String code) async {
    setState(() => _isDeploying = true);
    try {
      await ref
          .read(workersRepositoryProvider)
          .deployWorker(widget.worker.id, code);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deployed Successfully!')));
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          try {
            final data = e.response!.data;
            if (data is Map && data.containsKey('errors')) {
              errMsg = 'Cloudflare Error: ${data['errors']}';
            } else {
              errMsg = 'API Error: $data';
            }
          } catch (_) {}
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeploying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.worker.id),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.link), text: 'Bindings & Secrets'),
              Tab(icon: Icon(Icons.schedule), text: 'Triggers & Routes'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.code), text: 'Editor'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBindingsTab(),
            _buildTriggersTab(),
            _buildHistoryTab(),
            _buildEditorTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (widget.worker.id.startsWith('new-worker-')) {
      return const Center(child: Text('No history for new worker.'));
    }
    final historyAsync = ref.watch(workerDeploymentsProvider(widget.worker.id));
    return historyAsync.when(
      data: (deployments) {
        if (deployments.isEmpty) {
          return const Center(child: Text('No deployment history.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deployments.length,
          itemBuilder: (context, index) {
            final d = deployments[index];
            final isApi = d.source == 'api';
            final color = isApi ? Colors.blue : Colors.orange;
            final shortVer = d.versionId.length > 8 ? d.versionId.substring(0, 8) : d.versionId;

            // Format date
            String displayDate = d.createdOn;
            try {
              final dt = DateTime.parse(d.createdOn).toLocal();
              displayDate = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
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
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(isApi ? Icons.api : Icons.terminal, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.layers_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(shortVer, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(d.source.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(d.authorEmail, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(displayDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (e.toString().contains('10007') || e.toString().contains('not found')) {
          return const Center(child: Text('No history for new worker.'));
        }
        return Center(child: Text('Error: $e'));
      },
    );
  }


  Widget _buildBindingsTab() {
    if (widget.worker.id.startsWith('new-worker-')) {
      return const Center(
        child: Text('Please deploy the worker first to configure bindings.'),
      );
    }
    final bindingsAsync = ref.watch(workerBindingsProvider(widget.worker.id));
    final secretsAsync = ref.watch(workerSecretsProvider(widget.worker.id));

    return bindingsAsync.when(
      data: (bindings) {
        return secretsAsync.when(
          data: (secrets) {
            final allItems = [...bindings, ...secrets];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (bindings.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('Bindings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  ),
                  ...bindings.map((item) => _buildBindingCard(item, bindings)),
                  const SizedBox(height: 16),
                ],
                if (secrets.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('Secrets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  ),
                  ...secrets.map((item) => _buildSecretCard(item)),
                  const SizedBox(height: 16),
                ],
                if (allItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No bindings or secrets configured.')),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AddBindingDialog(workerId: widget.worker.id, currentBindings: bindings),
                        ),
                        icon: const Icon(Icons.add_link, size: 18),
                        label: const Text('Add Binding'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddSecretDialog(),
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text('Add Secret'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) {
            if (e.toString().contains('10007') ||
                e.toString().contains('not found')) {
              return const Center(
                child: Text(
                  'Please deploy the worker first to configure bindings.',
                ),
              );
            }
            return Center(child: Text('Error: $e'));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (e.toString().contains('10007') ||
            e.toString().contains('not found')) {
          return const Center(
            child: Text(
              'Please deploy the worker first to configure bindings.',
            ),
          );
        }
        return Center(child: Text('Error: $e'));
      },
    );
  }

  void _deleteSecret(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Secret?'),
        content: Text('Are you sure you want to delete the secret "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(workersRepositoryProvider)
          .deleteSecret(widget.worker.id, name);
      ref.invalidate(workerSecretsProvider(widget.worker.id));
      messenger.showSnackBar(const SnackBar(content: Text('Secret deleted.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Returns (icon, color, label) for a binding type
  (IconData, Color, String) _bindingTypeStyle(String type) {
    switch (type) {
      case 'd1':
        return (Icons.dataset, Colors.blue, 'D1 Database');
      case 'kv_namespace':
        return (Icons.storage, Colors.green, 'KV Namespace');
      case 'plain_text':
        return (Icons.text_fields, Colors.orange, 'Plain Text');
      case 'r2_bucket':
        return (Icons.folder, Colors.purple, 'R2 Bucket');
      case 'analytics_engine':
        return (Icons.bar_chart, Colors.teal, 'Analytics');
      case 'queue':
        return (Icons.queue, Colors.indigo, 'Queue');
      case 'service':
        return (Icons.hub, Colors.cyan, 'Service');
      default:
        return (Icons.settings, Colors.grey, type);
    }
  }

  Widget _buildBindingCard(WorkerBinding item, List<WorkerBinding> bindings) {
    final (icon, color, label) = _bindingTypeStyle(item.type);
    final detail = item.detail ?? '';
    // Truncate long UUIDs to first 8 chars
    final displayDetail = detail.length > 36
        ? '${detail.substring(0, 8)}...'
        : detail;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
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
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                      ),
                      if (displayDetail.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayDetail,
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: color, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddBindingDialog(
                      workerId: widget.worker.id,
                      currentBindings: bindings,
                      editBinding: item,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _deleteBinding(bindings, item.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretCard(WorkerSecret item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('Secret', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      const Text('••••••••••••', style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _showAddSecretDialog(editName: item.name),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _deleteSecret(item.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBinding(
    List<WorkerBinding> currentBindings,
    String nameToDelete,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Binding?'),
        content: Text(
          'Are you sure you want to delete the binding "$nameToDelete"?\nThis will redeploy your code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Redeploying to remove binding...')),
      );
      final newBindingsMap = currentBindings
          .where((b) => b.name != nameToDelete)
          .map((b) => b.toJson())
          .toList();
      await ref
          .read(workersRepositoryProvider)
          .updateBindings(widget.worker.id, newBindingsMap);
      ref.invalidate(workerBindingsProvider(widget.worker.id));
      messenger.showSnackBar(const SnackBar(content: Text('Binding deleted.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddSecretDialog({String? editName}) {
    final nameCtrl = TextEditingController(text: editName);
    final valCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editName == null ? 'Add Secret' : 'Edit Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Secret Name (e.g. API_KEY)',
              ),
              enabled:
                  editName == null, // disable name editing if it's an update
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: editName == null
                    ? 'Secret Value'
                    : 'New Secret Value',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || valCtrl.text.isEmpty) return;
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(workersRepositoryProvider)
                    .putSecret(widget.worker.id, nameCtrl.text, valCtrl.text);
                ref.invalidate(workerSecretsProvider(widget.worker.id));
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      editName == null ? 'Secret added.' : 'Secret updated.',
                    ),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(editName == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersTab() {
    if (widget.worker.id.startsWith('new-worker-')) {
      return const Center(
        child: Text('Please deploy the worker first to configure triggers.'),
      );
    }
    final schedulesAsync = ref.watch(workerSchedulesProvider(widget.worker.id));
    final domainsAsync = ref.watch(workerDomainsProvider);

    return schedulesAsync.when(
      data: (schedules) {
        return domainsAsync.when(
          data: (domains) {
            final workerDomains = domains.where((d) => d.service == widget.worker.id).toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section: Custom Domains / Routes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 4, height: 18,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2)),
                      ),
                      const Text('Custom Domains / Routes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ]),
                    TextButton.icon(
                      onPressed: () => _showAddDomainDialog(),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (workerDomains.isEmpty)
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
                        Text('No custom domains configured.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ...workerDomains.map((d) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.language, color: Colors.green, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.hostname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(d.environment, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          )),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 18, color: Colors.green),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            tooltip: 'Open in browser',
                            onPressed: () async {
                              final uri = Uri.tryParse('https://${d.hostname}');
                              if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _deleteDomain(d.id, d.hostname),
                          ),
                        ],
                      ),
                    ),
                  )),

                const SizedBox(height: 24),

                // Section: Cron Schedules
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 4, height: 18,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(2)),
                      ),
                      const Text('Cron Schedules', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ]),
                    TextButton.icon(
                      onPressed: () => _showAddScheduleDialog(schedules.map((e) => e.cron).toList()),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(foregroundColor: Colors.purple),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (schedules.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.schedule_outlined, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text('No cron schedules configured.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ...schedules.map((s) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.schedule, color: Colors.purple, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.cron, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                _describeCron(s.cron),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          )),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _showAddScheduleDialog(schedules.map((e) => e.cron).toList(), editCron: s.cron),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _deleteSchedule(schedules.map((e) => e.cron).toList(), s.cron),
                          ),
                        ],
                      ),
                    ),
                  )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) {
            if (e.toString().contains('10007') || e.toString().contains('not found')) {
              return const Center(child: Text('Please deploy the worker first to configure triggers.'));
            }
            return Center(child: Text('Error: $e'));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (e.toString().contains('10007') || e.toString().contains('not found')) {
          return const Center(child: Text('Please deploy the worker first to configure triggers.'));
        }
        return Center(child: Text('Error: $e'));
      },
    );
  }

  /// Returns a human-readable description for a cron expression
  String _describeCron(String cron) {
    const presets = {
      '* * * * *': 'Every minute',
      '*/5 * * * *': 'Every 5 minutes',
      '*/15 * * * *': 'Every 15 minutes',
      '*/30 * * * *': 'Every 30 minutes',
      '0 * * * *': 'Every hour',
      '0 */6 * * *': 'Every 6 hours',
      '0 */12 * * *': 'Every 12 hours',
      '0 0 * * *': 'Once a day (midnight)',
      '0 9 * * *': 'Every day at 9 AM',
      '0 0 * * 0': 'Every Sunday',
      '0 0 1 * *': 'First day of each month',
    };
    return presets[cron] ?? 'Custom schedule';
  }

  void _deleteSchedule(List<String> currentCrons, String cronToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule?'),
        content: Text(
          'Are you sure you want to delete the schedule "$cronToDelete"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final newCrons = currentCrons.where((c) => c != cronToDelete).toList();
      await ref
          .read(workersRepositoryProvider)
          .putSchedules(widget.worker.id, newCrons);
      ref.invalidate(workerSchedulesProvider(widget.worker.id));
      messenger.showSnackBar(
        const SnackBar(content: Text('Schedule deleted.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddScheduleDialog(List<String> currentCrons, {String? editCron}) {
    final cronCtrl = TextEditingController(text: editCron);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          editCron == null ? 'Add Cron Schedule' : 'Edit Cron Schedule',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: cronCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cron Expression',
                  hintText: 'e.g. * * * * * or */5 * * * *',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Common Presets',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('1 min'),
                    onPressed: () => cronCtrl.text = '* * * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('5 mins'),
                    onPressed: () => cronCtrl.text = '*/5 * * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('15 mins'),
                    onPressed: () => cronCtrl.text = '*/15 * * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('30 mins'),
                    onPressed: () => cronCtrl.text = '*/30 * * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('Hourly'),
                    onPressed: () => cronCtrl.text = '0 * * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('Daily'),
                    onPressed: () => cronCtrl.text = '0 0 * * *',
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('Weekly'),
                    onPressed: () => cronCtrl.text = '0 0 * * 0',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (cronCtrl.text.isEmpty) return;
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                // If editing, replace the old one. If adding, append it.
                final newCrons = List<String>.from(currentCrons);
                if (editCron != null) {
                  newCrons.remove(editCron);
                }
                newCrons.add(cronCtrl.text);

                await ref
                    .read(workersRepositoryProvider)
                    .putSchedules(widget.worker.id, newCrons);
                ref.invalidate(workerSchedulesProvider(widget.worker.id));
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      editCron == null
                          ? 'Schedule added.'
                          : 'Schedule updated.',
                    ),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(editCron == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteDomain(String domainId, String hostname) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Domain?'),
        content: Text('Are you sure you want to delete the domain "$hostname"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(workersRepositoryProvider).deleteDomain(domainId);
      ref.invalidate(workerDomainsProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Domain deleted.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddDomainDialog() {
    final hostnameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Domain'),
        content: TextField(
          controller: hostnameCtrl,
          decoration: const InputDecoration(
            labelText: 'Hostname',
            hintText: 'e.g. api.example.com',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (hostnameCtrl.text.isEmpty) return;
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(workersRepositoryProvider).addDomain(widget.worker.id, hostnameCtrl.text);
                ref.invalidate(workerDomainsProvider);
                messenger.showSnackBar(const SnackBar(content: Text('Domain added successfully.')));
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

  Widget _buildEditorTab() {
    if (widget.worker.id.startsWith('new-worker-')) {
      if (_codeController.text.isEmpty) {
        _codeController.text = '''export default {
  async fetch(request, env, ctx) {
    return new Response('Hello World!');
  },
};''';
      }
      return _buildEditorUI();
    }

    final contentAsync = ref.watch(workerContentProvider(widget.worker.id));
    return contentAsync.when(
      data: (content) {
        if (_codeController.text.isEmpty && content.isNotEmpty) {
          _codeController.text = content;
        }
        return _buildEditorUI();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (e.toString().contains('10007') ||
            e.toString().contains('not found')) {
          if (_codeController.text.isEmpty) {
            _codeController.text = '''export default {
  async fetch(request, env, ctx) {
    return new Response('Hello World!');
  },
};''';
          }
          return _buildEditorUI();
        }
        return Center(child: Text('Error: $e'));
      },
    );
  }

  Widget _buildEditorUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.amber.withValues(alpha: 0.1),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deploying from App overrides bindings (KV/D1). Use carefully for simple scripts only.',
                  style: TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TextField(
            controller: _codeController,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDeploying
                  ? null
                  : () => _deployCode(_codeController.text),
              icon: _isDeploying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Deploy Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddBindingDialog extends ConsumerStatefulWidget {
  final String workerId;
  final List<WorkerBinding> currentBindings;
  final WorkerBinding? editBinding;

  const AddBindingDialog({
    super.key,
    required this.workerId,
    required this.currentBindings,
    this.editBinding,
  });

  @override
  ConsumerState<AddBindingDialog> createState() => _AddBindingDialogState();
}

class _AddBindingDialogState extends ConsumerState<AddBindingDialog> {
  String _selectedType = 'plain_text';
  final _nameCtrl = TextEditingController();
  final _detailCtrl = TextEditingController(); // Used for plain_text value

  String? _selectedKvId;
  String? _selectedD1Id;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editBinding != null) {
      _selectedType = widget.editBinding!.type;
      _nameCtrl.text = widget.editBinding!.name;
      if (_selectedType == 'plain_text') {
        _detailCtrl.text = widget.editBinding!.detail ?? '';
      } else if (_selectedType == 'kv_namespace') {
        _selectedKvId = widget.editBinding!.detail;
      } else if (_selectedType == 'd1') {
        _selectedD1Id = widget.editBinding!.detail;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kvsAsync = ref.watch(kvNamespacesProvider);
    final d1sAsync = ref.watch(d1DatabasesProvider);

    return AlertDialog(
      title: Text(widget.editBinding == null ? 'Add Binding' : 'Edit Binding'),
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
              onChanged: widget.editBinding == null
                  ? (val) {
                      setState(() => _selectedType = val!);
                    }
                  : null, // Disable type change on edit
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Binding Name (e.g. DB, MY_KV, API_URL)',
              ),
              enabled: widget.editBinding == null,
            ),
            const SizedBox(height: 8),
            if (_selectedType == 'plain_text')
              TextField(
                controller: _detailCtrl,
                decoration: const InputDecoration(labelText: 'Value'),
              )
            else if (_selectedType == 'kv_namespace')
              kvsAsync.when(
                data: (kvs) => DropdownButtonFormField<String>(
                  initialValue: _selectedKvId,
                  decoration: const InputDecoration(
                    labelText: 'Select KV Namespace',
                  ),
                  items: kvs
                      .map(
                        (k) =>
                            DropdownMenuItem(value: k.id, child: Text(k.title)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedKvId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text(
                  'Error loading KVs: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_selectedType == 'd1')
              d1sAsync.when(
                data: (d1s) => DropdownButtonFormField<String>(
                  initialValue: _selectedD1Id,
                  decoration: const InputDecoration(
                    labelText: 'Select D1 Database',
                  ),
                  items: d1s
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.uuid,
                          child: Text(d.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedD1Id = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text(
                  'Error loading D1s: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  widget.editBinding == null ? 'Add (Deploy)' : 'Update (Deploy)',
                ),
        ),
      ],
    );
  }

  void _save() async {
    if (_nameCtrl.text.isEmpty) return;

    String? detail;
    if (_selectedType == 'plain_text') {
      if (_detailCtrl.text.isEmpty) return;
      detail = _detailCtrl.text;
    } else if (_selectedType == 'kv_namespace') {
      if (_selectedKvId == null) return;
      detail = _selectedKvId;
    } else if (_selectedType == 'd1') {
      if (_selectedD1Id == null) return;
      detail = _selectedD1Id;
    }

    final newBinding = WorkerBinding(
      name: _nameCtrl.text,
      type: _selectedType,
      detail: detail,
    );

    // Filter out old binding with same name if editing
    final currentMapList = widget.currentBindings
        .where((b) => b.name != newBinding.name)
        .map((b) => b.toJson())
        .toList();

    currentMapList.add(newBinding.toJson());

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(workersRepositoryProvider)
          .updateBindings(widget.workerId, currentMapList);
      ref.invalidate(workerBindingsProvider(widget.workerId));
      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.editBinding == null
                  ? 'Binding added successfully!'
                  : 'Binding updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
