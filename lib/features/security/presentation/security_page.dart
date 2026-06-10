import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? 'Development Mode Enabled'
                  : 'Development Mode Disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Security Level updated to $newLevel')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSavingSecLevel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devModeAsync = ref.watch(devModeProvider(widget.zoneId));
    final secLevelAsync = ref.watch(securityLevelProvider(widget.zoneId));

    return Scaffold(
      appBar: AppBar(title: Text('Security: ${widget.zoneName}')),
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
                      const SizedBox(width: 12),
                      Text(
                        'I\'m Under Attack Mode',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Defend against DDoS attacks. Visitors will see a JavaScript challenge.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isUnderAttack
                                      ? 'TURN OFF'
                                      : 'ENABLE UNDER ATTACK MODE',
                                ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error loading status: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Security Level Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Level',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Adjust your website\'s security profile.'),
                  const SizedBox(height: 16),
                  secLevelAsync.when(
                    data: (level) {
                      if (level == 'under_attack') {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Under Attack mode is enabled. To change the level, please turn it off first.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: level,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'essentially_off',
                            child: Text('Essentially Off'),
                          ),
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(value: 'high', child: Text('High')),
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
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error loading status: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                      const SizedBox(width: 12),
                      Text(
                        'Development Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Temporarily bypass our cache. Allows you to see changes to your origin server in real-time. Automatically turns off after 3 hours.',
                  ),
                  const SizedBox(height: 16),
                  devModeAsync.when(
                    data: (isDevMode) {
                      return SwitchListTile(
                        title: Text(
                          isDevMode ? 'Active (Bypassing Cache)' : 'Off',
                        ),
                        value: isDevMode,
                        onChanged: _isSavingDevMode
                            ? null
                            : (val) => _toggleDevMode(val),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: Colors.orange,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error loading status: $e'),
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
