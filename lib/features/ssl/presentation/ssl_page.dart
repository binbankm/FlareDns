import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ssl_repository.dart';
import '../providers/ssl_provider.dart';
import '../../zones/providers/zones_provider.dart';

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
          final certsAsync = ref.watch(zoneSslCertificatesProvider(widget.zoneId));
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
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
                      const Text('Choose how Cloudflare connects to your origin server.', style: TextStyle(color: Colors.grey)),
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
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge, color: Colors.purpleAccent, size: 28),
                          const SizedBox(width: 12),
                          Text('Edge Certificates', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Active certificates protecting your domain.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      certsAsync.when(
                        data: (certs) {
                          if (certs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No edge certificates found.'),
                            );
                          }
                          return Column(
                            children: certs.map((cert) {
                              final hosts = (cert['hosts'] as List<dynamic>?)?.cast<String>() ?? [];
                              final status = cert['status'] ?? 'unknown';
                              final type = cert['type'] ?? 'universal';
                              final color = status == 'active' ? Colors.green : Colors.orange;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          type.toString().toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status.toString().toUpperCase(),
                                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Hosts:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: hosts.map((h) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                        ),
                                        child: Text(h, style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error loading certificates: $err', style: const TextStyle(color: Colors.red)),
                        ),
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
