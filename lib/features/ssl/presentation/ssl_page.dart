import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../data/ssl_repository.dart';
import '../providers/ssl_provider.dart';
import '../../zones/providers/zones_provider.dart';

class SslPage extends ConsumerStatefulWidget {
  final String zoneId;
  final String zoneName;

  const SslPage({super.key, required this.zoneId, required this.zoneName});

  @override
  ConsumerState<SslPage> createState() => _SslPageState();
}

class _SslPageState extends ConsumerState<SslPage> {
  bool _isSaving = false;

  List<Map<String, String>> _getModes(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': 'off', 'title': l10n.sslModeOff, 'desc': l10n.sslModeOffDesc},
      {
        'value': 'flexible',
        'title': l10n.sslModeFlexible,
        'desc': l10n.sslModeFlexibleDesc,
      },
      {
        'value': 'full',
        'title': l10n.sslModeFull,
        'desc': l10n.sslModeFullDesc,
      },
      {
        'value': 'strict',
        'title': l10n.sslModeStrict,
        'desc': l10n.sslModeStrictDesc,
      },
    ];
  }

  Future<void> _updateMode(String newMode) async {
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(sslRepositoryProvider);
      await repository.setSslMode(widget.zoneId, newMode);
      ref.invalidate(sslModeProvider(widget.zoneId));
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.sslUpdated),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sslState = ref.watch(sslModeProvider(widget.zoneId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sslTitle(widget.zoneName))),
      body: sslState.when(
        data: (currentMode) {
          final certsAsync = ref.watch(
            zoneSslCertificatesProvider(widget.zoneId),
          );

          return ListView(
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
                            Icons.security,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            l10n.sslEncryptionMode,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        l10n.sslEncryptionModeDesc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 24),
                      ..._getModes(context).map((mode) {
                        return RadioListTile<String>(
                          title: Text(
                            mode['title']!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(mode['desc']!),
                          value: mode['value']!,
                          // ignore: deprecated_member_use
                          groupValue: currentMode,
                          activeColor: Theme.of(context).colorScheme.primary,
                          // ignore: deprecated_member_use
                          onChanged: _isSaving
                              ? null
                              : (val) {
                                  if (val != null && val != currentMode) {
                                    _updateMode(val);
                                  }
                                },
                        );
                      }),
                      if (_isSaving)
                        Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            l10n.sslEdgeCertificates,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        l10n.sslEdgeCertificatesDesc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 16),
                      certsAsync.when(
                        data: (certs) {
                          if (certs.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(l10n.sslNoCerts),
                            );
                          }
                          return Column(
                            children: certs.map((cert) {
                              final hosts =
                                  (cert['hosts'] as List<dynamic>?)
                                      ?.cast<String>() ??
                                  [];
                              final status = cert['status'] ?? 'unknown';
                              final type = cert['type'] ?? 'universal';
                              final color = status == 'active'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          type.toString().toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            status.toString().toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      l10n.sslHosts,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: hosts
                                          .map(
                                            (h) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.onPrimary.withValues(
                                                  alpha: 0.05,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Theme.of(context).colorScheme.onPrimary
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                              child: Text(
                                                h,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            l10n.sslCertError(err.toString()),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context).commonError(err.toString()), textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sslModeProvider(widget.zoneId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
