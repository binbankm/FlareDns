import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../data/cache_repository.dart';

class CachePage extends ConsumerStatefulWidget {
  final String zoneId;
  final String zoneName;

  const CachePage({super.key, required this.zoneId, required this.zoneName});

  @override
  ConsumerState<CachePage> createState() => _CachePageState();
}

class _CachePageState extends ConsumerState<CachePage> {
  bool _isPurging = false;

  Future<void> _purgeAll() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cachePurgeConfirmTitle),
        content: Text(l10n.cachePurgeConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.cachePurge),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isPurging = true);
    try {
      final repository = ref.read(cacheRepositoryProvider);
      await repository.purgeAll(widget.zoneId);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cachePurgeSuccess),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).commonError(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isPurging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cachingTitle(widget.zoneName))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.delete_sweep,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        l10n.cachePurgeTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.cachePurgeDesc,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isPurging ? null : _purgeAll,
                      icon: _isPurging
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.warning),
                      label: Text(
                        _isPurging ? l10n.cachePurging : l10n.cachePurgeButton,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
