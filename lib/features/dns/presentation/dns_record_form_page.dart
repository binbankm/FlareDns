import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
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
    'A',
    'AAAA',
    'CNAME',
    'TXT',
    'MX',
    'NS',
    'SRV',
    'LOC',
    'CAA',
    'HTTPS',
    'SVCB',
    'URI',
    'PTR',
    'CERT',
    'DNSKEY',
    'DS',
    'NAPTR',
    'SMIMEA',
    'SSHFP',
    'TLSA',
  ];

  Map<int, String> _ttlOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      1: l10n.dnsTtlAuto,
      60: l10n.dnsTtlMins(1),
      120: l10n.dnsTtlMins(2),
      300: l10n.dnsTtlMins(5),
      600: l10n.dnsTtlMins(10),
      900: l10n.dnsTtlMins(15),
      1800: l10n.dnsTtlMins(30),
      3600: l10n.dnsTtlHours(1),
      7200: l10n.dnsTtlHours(2),
      18000: l10n.dnsTtlHours(5),
      43200: l10n.dnsTtlHours(12),
      86400: l10n.dnsTtlDays(1),
    };
  }

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
    _priorityController = TextEditingController(
      text: record?.priority?.toString() ?? '10',
    );

    _ttl = record?.ttl ?? 1;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).commonError(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateContent(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context).dnsFormContentRequired;

    if (_type == 'A') {
      final ipv4RegExp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipv4RegExp.hasMatch(value)) return AppLocalizations.of(context).dnsFormInvalidIpv4;

      final parts = value.split('.');
      for (final p in parts) {
        final val = int.tryParse(p);
        if (val == null || val < 0 || val > 255) return AppLocalizations.of(context).dnsFormInvalidIpv4Segment;
      }
    } else if (_type == 'AAAA') {
      if (!value.contains(':')) return AppLocalizations.of(context).dnsFormInvalidIpv6;
    }

    return null;
  }

  String _getHintForType() {
    switch (_type) {
      case 'A':
        return '192.0.2.1';
      case 'AAAA':
        return '2001:db8::1';
      case 'CNAME':
        return 'target.example.com';
      case 'TXT':
        return 'v=spf1 include:_spf.example.com ~all';
      case 'MX':
        return 'mail.example.com';
      case 'NS':
        return 'ns1.example.com';
      case 'SRV':
        return AppLocalizations.of(context).dnsFormHintSrv;
      default:
        return AppLocalizations.of(context).dnsFormHintDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;
    final canProxy = ['A', 'AAAA', 'CNAME'].contains(_type);
    final requiresPriority = ['MX', 'SRV', 'URI'].contains(_type);
    final l10n = AppLocalizations.of(context);
    final ttlOptions = _ttlOptions(context);
    if (!ttlOptions.containsKey(_ttl)) {
      ttlOptions[_ttl] = l10n.dnsTtlSec(_ttl);
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? l10n.dnsFormEditTitle : l10n.dnsFormAddTitle)),
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
                decoration: InputDecoration(labelText: l10n.dnsFormType),
                items: _supportedTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
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
              SizedBox(height: 16),

              // Name Field with @ helper
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.dnsFormName,
                        hintText: l10n.dnsFormNameHint,
                      ),
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : l10n.dnsFormNameRequired,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _nameController.text = '@';
                        });
                      },
                      child: Text('@'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Priority Field (Conditional)
              if (requiresPriority) ...[
                TextFormField(
                  controller: _priorityController,
                  decoration: InputDecoration(
                    labelText: l10n.dnsFormPriority,
                    hintText: l10n.dnsFormPriorityHint,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return l10n.dnsFormPriorityRequired;
                    }
                    if (int.tryParse(val) == null) {
                      return l10n.dnsFormPriorityInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],

              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n.dnsFormContent,
                  hintText: _getHintForType(),
                ),
                maxLines: _type == 'TXT' ? 3 : 1,
                validator: _validateContent,
              ),
              SizedBox(height: 16),

              // TTL Dropdown
              DropdownButtonFormField<int>(
                initialValue: _ttl,
                decoration: InputDecoration(
                  labelText: l10n.dnsFormTtl,
                  border: OutlineInputBorder(),
                ),
                items: ttlOptions.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: _proxied
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _ttl = val;
                          });
                        }
                      },
                hint: _proxied ? Text(l10n.dnsFormTtlAutoEnforced) : null,
              ),
              if (_proxied)
                Padding(
                  padding: EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Text(
                    l10n.dnsFormTtlLocked,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              SizedBox(height: 16),

              // Proxy Switch
              if (canProxy)
                SwitchListTile(
                  title: Text(l10n.dnsFormProxied),
                  subtitle: Text(l10n.dnsFormProxiedSubtitle),
                  value: _proxied,
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
              SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: _isSaving ? null : _save,

                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? l10n.dnsFormSaveChanges : l10n.dnsFormCreateRecord),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
