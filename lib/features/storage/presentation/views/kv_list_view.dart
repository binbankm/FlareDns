import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../../providers/storage_providers.dart';
import '../../data/storage_repository.dart';

class KVListView extends ConsumerWidget {
  const KVListView({super.key});

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentTitle,
  ) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).storageEditKVTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: AppLocalizations.of(context).storageEditKVPrompt),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = controller.text.trim();
                if (title.isEmpty || title == currentTitle) {
                  Navigator.pop(context);
                  return;
                }
                final l10n = AppLocalizations.of(context);
                final successMsg = l10n.storageUpdateKVSuccess;
                final errorMsg = l10n.commonError;
                
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await ref
                      .read(storageRepositoryProvider)
                      .updateKVNamespace(id, title);
                  ref.invalidate(kvNamespacesProvider);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(successMsg),
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(errorMsg(e.toString()))),
                  );
                }
              },
              child: Text(AppLocalizations.of(context).commonSave),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).storageDeleteTitle(AppLocalizations.of(context).pageDashboardKV)),
          content: Text(
            AppLocalizations.of(context).storageDeleteContent(title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () async {
                final l10n = AppLocalizations.of(context);
                final successMsg = l10n.storageDeleteSuccess(l10n.pageDashboardKV);
                final errorMsg = l10n.commonError;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await ref
                      .read(storageRepositoryProvider)
                      .deleteKVNamespace(id);
                  ref.invalidate(kvNamespacesProvider);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(successMsg),
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(errorMsg(e.toString()))),
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context).commonDelete,
                
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namespacesAsync = ref.watch(kvNamespacesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return namespacesAsync.when(
      data: (namespaces) {
        if (namespaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 64,
                  color: colorScheme.outlineVariant,
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).storageNoItems(AppLocalizations.of(context).pageDashboardKV),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: namespaces.length,
          itemBuilder: (context, index) {
            final namespace = namespaces[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.storage, color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namespace.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: namespace.id),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).storageCopyId),
                                ),
                              );
                            },
                            child: Text(
                              'ID: ${namespace.id}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(
                            context,
                            ref,
                            namespace.id,
                            namespace.title,
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(
                            context,
                            ref,
                            namespace.id,
                            namespace.title,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: Theme.of(context).colorScheme.primary),
                              SizedBox(width: 12),
                              Text(AppLocalizations.of(context).storageRename),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error),
                              SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context).commonDelete,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context).commonError(error.toString()), textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(kvNamespacesProvider),
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
