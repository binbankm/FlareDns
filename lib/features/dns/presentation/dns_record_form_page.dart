import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/dns_record.dart';
import '../data/dns_repository.dart';
import '../providers/dns_provider.dart';

class DnsRecordFormPage extends ConsumerStatefulWidget {
  final String zoneId;
  final DnsRecord? existingRecord;

  const DnsRecordFormPage({
    super.key,
    required this.zoneId,
    this.existingRecord,
  });

  @override
  ConsumerState<DnsRecordFormPage> createState() => _DnsRecordFormPageState();
}

class _DnsRecordFormPageState extends ConsumerState<DnsRecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late String _type;
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late TextEditingController _priorityController;
  late int _ttl;
  late bool _proxied;

  bool _isSaving = false;

  final List<String> _supportedTypes = [
    'A', 'AAAA', 'CNAME', 'TXT', 'MX', 'NS', 'SRV', 'LOC', 'CAA', 'HTTPS', 'SVCB', 'URI', 'PTR', 'CERT', 'DNSKEY', 'DS', 'NAPTR', 'SMIMEA', 'SSHFP', 'TLSA'
  ];

  final Map<int, String> _ttlOptions = {
    1: 'Auto',
    60: '1 min',
    120: '2 min',
    300: '5 min',
    600: '10 min',
    900: '15 min',
    1800: '30 min',
    3600: '1 hour',
    7200: '2 hours',
    18000: '5 hours',
    43200: '12 hours',
    86400: '1 day',
  };

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;
    _type = record?.type ?? 'A';
    if (!_supportedTypes.contains(_type)) {
      _supportedTypes.add(_type);
    }
    _nameController = TextEditingController(text: record?.name ?? '');
    _contentController = TextEditingController(text: record?.content ?? '');
    _priorityController = TextEditingController(text: record?.priority?.toString() ?? '10');
    
    _ttl = record?.ttl ?? 1;
    if (!_ttlOptions.containsKey(_ttl)) {
      _ttlOptions[_ttl] = '$_ttl sec';
    }

    _proxied = record?.proxied ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(dnsRepositoryProvider);
      
      int? priority;
      if (['MX', 'SRV', 'URI'].contains(_type)) {
        priority = int.tryParse(_priorityController.text) ?? 10;
      }

      final newRecord = DnsRecord(
        id: widget.existingRecord?.id ?? '',
        type: _type,
        name: _nameController.text.trim(),
        content: _contentController.text.trim(),
        proxied: _proxied,
        ttl: _ttl,
        priority: priority,
      );

      if (widget.existingRecord == null) {
        await repository.createDnsRecord(widget.zoneId, newRecord);
      } else {
        await repository.updateDnsRecord(widget.zoneId, newRecord);
      }

      ref.invalidate(dnsRecordsProvider(widget.zoneId));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateContent(String? value) {
    if (value == null || value.isEmpty) return 'Content is required';
    
    if (_type == 'A') {
      final ipv4RegExp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipv4RegExp.hasMatch(value)) return 'Invalid IPv4 address';
      
      final parts = value.split('.');
      for (final p in parts) {
        final val = int.tryParse(p);
        if (val == null || val < 0 || val > 255) return 'Invalid IPv4 segment';
      }
    } else if (_type == 'AAAA') {
      if (!value.contains(':')) return 'Invalid IPv6 address';
    }
    
    return null;
  }

  String _getHintForType() {
    switch (_type) {
      case 'A': return '192.0.2.1';
      case 'AAAA': return '2001:db8::1';
      case 'CNAME': return 'target.example.com';
      case 'TXT': return 'v=spf1 include:_spf.example.com ~all';
      case 'MX': return 'mail.example.com';
      case 'NS': return 'ns1.example.com';
      case 'SRV': return 'Target (e.g. example.com). For SRV use data API for full control, or format content appropriately.';
      default: return 'Value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;
    final canProxy = ['A', 'AAAA', 'CNAME'].contains(_type);
    final requiresPriority = ['MX', 'SRV', 'URI'].contains(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Record' : 'Add Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selection
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: _supportedTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _type = val;
                      if (!['A', 'AAAA', 'CNAME'].contains(_type)) {
                        _proxied = false;
                      }
                      if (_ttl == 1 && _proxied == false) {
                         // Note: Proxied records usually enforce Auto TTL
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Name Field with @ helper
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g., www or @ for root',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val != null && val.isNotEmpty ? null : 'Name is required',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _nameController.text = '@';
                        });
                      },
                      child: const Text('@'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority Field (Conditional)
              if (requiresPriority) ...[
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    hintText: 'e.g., 10',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Priority is required';
                    if (int.tryParse(val) == null) return 'Must be a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  hintText: _getHintForType(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: _type == 'TXT' ? 3 : 1,
                validator: _validateContent,
              ),
              const SizedBox(height: 16),

              // TTL Dropdown
              DropdownButtonFormField<int>(
                initialValue: _ttl,
                decoration: const InputDecoration(labelText: 'TTL', border: OutlineInputBorder()),
                items: _ttlOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: _proxied ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _ttl = val;
                    });
                  }
                },
                hint: _proxied ? const Text('Auto (Enforced by Proxy)') : null,
              ),
              if (_proxied)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Text('TTL is locked to Auto when proxied', style: TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              const SizedBox(height: 16),

              // Proxy Switch
              if (canProxy)
                SwitchListTile(
                  title: const Text('Proxied'),
                  subtitle: const Text('Route traffic through Cloudflare'),
                  value: _proxied,
                  activeThumbColor: Colors.orange,
                  onChanged: (val) {
                    setState(() {
                      _proxied = val;
                      if (_proxied) {
                        _ttl = 1; // Auto
                      }
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEditing ? 'Save Changes' : 'Create Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
