import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../data/security_repository.dart';
import '../providers/security_provider.dart';

class SecurityPage extends ConsumerStatefulWidget {
  final String zoneId;
  final String zoneName;

  const SecurityPage({super.key, required this.zoneId, required this.zoneName});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  bool _isSavingDevMode = false;
  bool _isSavingSecLevel = false;

  Future<void> _toggleDevMode(bool newValue) async {
    setState(() => _isSavingDevMode = true);
    try {
      final repo = ref.read(securityRepositoryProvider);
      await repo.setDevelopmentMode(widget.zoneId, newValue ? 'on' : 'off');
      ref.invalidate(devModeProvider(widget.zoneId));
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? l10n.securityDevModeEnabled
                  : l10n.securityDevModeDisabled,
            ),
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
      if (mounted) setState(() => _isSavingDevMode = false);
    }
  }

  Future<void> _changeSecurityLevel(String newLevel) async {
    setState(() => _isSavingSecLevel = true);
    try {
      final repo = ref.read(securityRepositoryProvider);
      await repo.setSecurityLevel(widget.zoneId, newLevel);
      ref.invalidate(securityLevelProvider(widget.zoneId));
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.securityLevelUpdated(newLevel))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).commonError(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isSavingSecLevel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devModeAsync = ref.watch(devModeProvider(widget.zoneId));
    final secLevelAsync = ref.watch(securityLevelProvider(widget.zoneId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.securityTitle(widget.zoneName))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Under Attack Mode Card
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield,
                        color: Theme.of(context).colorScheme.error,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        l10n.securityUnderAttackTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.securityUnderAttackDesc,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  SizedBox(height: 16),
                  secLevelAsync.when(
                    data: (level) {
                      final isUnderAttack = level == 'under_attack';
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isUnderAttack
                                ? Colors.white
                                : Theme.of(context).colorScheme.error,
                            foregroundColor: isUnderAttack
                                ? Theme.of(context).colorScheme.error
                                : Colors.white,
                          ),
                          onPressed: _isSavingSecLevel
                              ? null
                              : () {
                                  _changeSecurityLevel(
                                    isUnderAttack ? 'medium' : 'under_attack',
                                  );
                                },
                          child: _isSavingSecLevel
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isUnderAttack
                                      ? l10n.securityUnderAttackTurnOff
                                      : l10n.securityUnderAttackEnable,
                                ),
                        ),
                      );
                    },
                    loading: () =>
                        Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text(l10n.securityErrorLoading(e.toString())),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Security Level Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.securityLevelTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(l10n.securityLevelDesc),
                  SizedBox(height: 16),
                  secLevelAsync.when(
                    data: (level) {
                      if (level == 'under_attack') {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            l10n.securityLevelUnderAttackNote,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: level,
                        decoration: const InputDecoration(),
                        items: [
                          DropdownMenuItem(
                            value: 'essentially_off',
                            child: Text(l10n.securityLevelEssentiallyOff),
                          ),
                          DropdownMenuItem(value: 'low', child: Text(l10n.securityLevelLow)),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text(l10n.securityLevelMedium),
                          ),
                          DropdownMenuItem(value: 'high', child: Text(l10n.securityLevelHigh)),
                        ],
                        onChanged: _isSavingSecLevel
                            ? null
                            : (val) {
                                if (val != null && val != level) {
                                  _changeSecurityLevel(val);
                                }
                              },
                      );
                    },
                    loading: () =>
                        Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text(l10n.securityErrorLoading(e.toString())),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Development Mode Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.build,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        l10n.securityDevModeTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.securityDevModeDesc,
                  ),
                  SizedBox(height: 16),
                  devModeAsync.when(
                    data: (isDevMode) {
                      return SwitchListTile(
                        title: Text(
                          isDevMode ? l10n.securityDevModeActive : l10n.securityDevModeOff,
                        ),
                        value: isDevMode,
                        onChanged: _isSavingDevMode
                            ? null
                            : (val) => _toggleDevMode(val),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                    loading: () =>
                        Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text(l10n.securityErrorLoading(e.toString())),
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
