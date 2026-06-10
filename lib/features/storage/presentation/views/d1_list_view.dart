import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../../providers/storage_providers.dart';
import '../../data/storage_repository.dart';

class D1ListView extends ConsumerWidget {
  const D1ListView({super.key});

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).storageDeleteTitle(AppLocalizations.of(context).pageDashboardD1)),
          content: Text(
            AppLocalizations.of(context).storageDeleteContent(name),
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
                final successMsg = l10n.storageDeleteSuccess(l10n.pageDashboardD1);
                final errorMsg = l10n.commonError;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await ref
                      .read(storageRepositoryProvider)
                      .deleteD1Database(id);
                  ref.invalidate(d1DatabasesProvider);
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
    final databasesAsync = ref.watch(d1DatabasesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return databasesAsync.when(
      data: (databases) {
        if (databases.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dataset_outlined,
                  size: 64,
                  color: colorScheme.outlineVariant,
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).storageNoItems(AppLocalizations.of(context).pageDashboardD1),
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
          itemCount: databases.length,
          itemBuilder: (context, index) {
            final database = databases[index];
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
                      child: Icon(Icons.dataset, color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            database.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: database.uuid),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).storageCopyUuid),
                                ),
                              );
                            },
                            child: Text(
                              'UUID: ${database.uuid}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (database.createdAt != null) ...[
                            SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).storageCreated(database.createdAt!),
                              style: TextStyle(
                                color: colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteDialog(
                            context,
                            ref,
                            database.uuid,
                            database.name,
                          );
                        }
                      },
                      itemBuilder: (context) => [
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
                onPressed: () => ref.invalidate(d1DatabasesProvider),
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
