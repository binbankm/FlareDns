import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../../providers/storage_providers.dart';
import '../../data/storage_repository.dart';

class R2ListView extends ConsumerWidget {
  const R2ListView({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).storageDeleteTitle(AppLocalizations.of(context).pageDashboardR2)),
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
                final successMsg = l10n.storageDeleteSuccess(l10n.pageDashboardR2);
                final errorMsg = l10n.commonError;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await ref
                      .read(storageRepositoryProvider)
                      .deleteR2Bucket(name);
                  ref.invalidate(r2BucketsProvider);
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
    final bucketsAsync = ref.watch(r2BucketsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return bucketsAsync.when(
      data: (buckets) {
        if (buckets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: 64,
                  color: colorScheme.outlineVariant,
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).storageNoItems(AppLocalizations.of(context).pageDashboardR2),
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
          itemCount: buckets.length,
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.cloud, color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bucket.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (bucket.creationDate != null) ...[
                            SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).storageCreated(bucket.creationDate!),
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
                          _showDeleteDialog(context, ref, bucket.name);
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
                onPressed: () => ref.invalidate(r2BucketsProvider),
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
