import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ssl_repository.dart';
import '../providers/ssl_provider.dart';

class SslPage extends ConsumerStatefulWidget {
  final String zoneId;
  final String zoneName;

  const SslPage({
    super.key,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  ConsumerState<SslPage> createState() => _SslPageState();
}

class _SslPageState extends ConsumerState<SslPage> {
  bool _isSaving = false;

  final List<Map<String, String>> _modes = [
    {'value': 'off', 'title': 'Off', 'desc': 'No encryption applied.'},
    {'value': 'flexible', 'title': 'Flexible', 'desc': 'Encrypts traffic between the browser and Cloudflare.'},
    {'value': 'full', 'title': 'Full', 'desc': 'Encrypts end-to-end, using a self-signed cert on the server.'},
    {'value': 'strict', 'title': 'Full (strict)', 'desc': 'Encrypts end-to-end, requires a trusted CA or Cloudflare Origin CA cert on the server.'},
  ];

  Future<void> _updateMode(String newMode) async {
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(sslRepositoryProvider);
      await repository.setSslMode(widget.zoneId, newMode);
      ref.invalidate(sslModeProvider(widget.zoneId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SSL/TLS mode updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sslState = ref.watch(sslModeProvider(widget.zoneId));

    return Scaffold(
      appBar: AppBar(title: Text('SSL/TLS: ${widget.zoneName}')),
      body: sslState.when(
        data: (currentMode) {
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
                          Icon(Icons.security, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Text('Encryption Mode', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Choose how Cloudflare connects to your origin server.'),
                      const SizedBox(height: 24),
                      ..._modes.map((mode) {
                        return RadioListTile<String>(
                          title: Text(mode['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sslModeProvider(widget.zoneId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
