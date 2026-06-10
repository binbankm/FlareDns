import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workers_provider.dart';
import '../data/workers_repository.dart';
import '../domain/worker.dart';
import 'package:go_router/go_router.dart';

class WorkersListPage extends ConsumerStatefulWidget {
  const WorkersListPage({super.key});

  @override
  ConsumerState<WorkersListPage> createState() => _WorkersListPageState();
}

class _WorkersListPageState extends ConsumerState<WorkersListPage> {
  String _searchQuery = '';

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  /// Returns (icon, color) for a given handler type
  (IconData, Color) _handlerStyle(BuildContext context, String handler) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (handler) {
      case 'fetch':
        return (Icons.http_rounded, colorScheme.primary);
      case 'scheduled':
        return (Icons.schedule, colorScheme.secondary);
      case 'queue':
        return (Icons.queue, colorScheme.tertiary);
      case 'tail':
        return (Icons.receipt_long, colorScheme.primary);
      case 'email':
        return (Icons.email, colorScheme.error);
      case 'rpc':
        return (Icons.hub, colorScheme.secondary);
      default:
        return (Icons.bolt, colorScheme.tertiary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersAsyncValue = ref.watch(workersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Workers'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.invalidate(workersProvider),
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
                    hintText: 'Search workers...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),
            ),
          ),
          Expanded(
            child: workersAsyncValue.when(
              data: (workers) {
                if (workers.isEmpty) {
                  return Center(
                    child: Text('No Workers found in your account.'),
                  );
                }

                final filtered = workers
                    .where((w) => w.id.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No workers match your search.'),
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
                        final worker = filtered[index];
                        final primaryHandler = worker.handlers.isNotEmpty
                            ? worker.handlers.first
                            : 'fetch';
                        final (icon, iconColor) = _handlerStyle(context, primaryHandler);
                        final isStandard = worker.usageModel == 'standard';

                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.push(
                              '/worker/${worker.id}',
                              extra: worker,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: iconColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: iconColor,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.id,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        // Handler chips
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            ...worker.handlers.map((h) {
                                              final (hIcon, hColor) =
                                                  _handlerStyle(context, h);
                                              return _Chip(
                                                icon: hIcon,
                                                label: h,
                                                color: hColor,
                                              );
                                            }),
                                            _Chip(
                                              icon: isStandard
                                                  ? Icons.star
                                                  : Icons.flash_on,
                                              label: worker.usageModel,
                                              color: isStandard
                                                  ? Theme.of(context).colorScheme.secondaryContainer
                                                  : Theme.of(context).colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.update,
                                              size: 12,
                                              color: Theme.of(context).colorScheme.outline,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _formatDate(worker.modifiedOn),
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
                                  // Delete + Arrow
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                'Delete Worker',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete "${worker.id}"? This action cannot be undone.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      context.pop(false),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      context.pop(true),
                                                  child: Text(
                                                    'Delete',
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
                                                    workersRepositoryProvider,
                                                  )
                                                  .deleteWorker(worker.id);
                                              ref.invalidate(workersProvider);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Worker deleted.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                      SizedBox(height: 8),
                                      Icon(
                                        Icons.chevron_right,
                                        color: colorScheme.outline,
                                        size: 20,
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
                    Text('Error: $error', textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(workersProvider),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameCtrl = TextEditingController();
          final String? workerName = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Create New Worker'),
              content: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Worker Name',
                  hintText: 'e.g. my-awesome-worker',
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      Navigator.pop(context, nameCtrl.text);
                    }
                  },
                  child: Text('Create'),
                ),
              ],
            ),
          );

          if (workerName != null && workerName.isNotEmpty && context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  Center(child: CircularProgressIndicator()),
            );

            try {
              final defaultCode = '''export default {
  async fetch(request, env, ctx) {
    return new Response('Hello World from ' + request.url);
  },
};''';
              await ref
                  .read(workersRepositoryProvider)
                  .deployWorker(workerName, defaultCode);
              ref.invalidate(workersProvider);

              if (context.mounted) {
                Navigator.pop(context); // pop loading
                final newWorker = CloudflareWorker(
                  id: workerName,
                  createdOn: DateTime.now().toIso8601String(),
                  modifiedOn: DateTime.now().toIso8601String(),
                  usageModel: 'standard',
                  handlers: ['fetch'],
                );
                // Navigate to dashboard which has the editor, and default to the Editor tab (index 3)
                context.push(
                  '/worker/${newWorker.id}?initialTab=3',
                  extra: newWorker,
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context); // pop loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating worker: $e')),
                );
              }
            }
          }
        },
        tooltip: 'New Worker',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
