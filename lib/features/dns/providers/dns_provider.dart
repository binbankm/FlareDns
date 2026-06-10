import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dns_record.dart';
import '../data/dns_repository.dart';

// Provider to fetch DNS records for a specific zone
final dnsRecordsProvider = FutureProvider.family<List<DnsRecord>, String>((ref, zoneId) async {
  final repository = ref.watch(dnsRepositoryProvider);
  return repository.getDnsRecords(zoneId);
});

// Provider to handle mutations (create, update, delete, patch proxied)
final dnsMutationProvider = Provider<DnsMutationService>((ref) {
  return DnsMutationService(ref);
});

class DnsMutationService {
  final Ref _ref;
  DnsMutationService(this._ref);

  Future<void> toggleProxied(String zoneId, DnsRecord record, bool proxied) async {
    final repository = _ref.read(dnsRepositoryProvider);
    await repository.patchDnsRecordProxied(zoneId, record, proxied);
    _ref.invalidate(dnsRecordsProvider(zoneId));
  }

  Future<void> deleteRecord(String zoneId, String recordId) async {
    final repository = _ref.read(dnsRepositoryProvider);
    await repository.deleteDnsRecord(zoneId, recordId);
    _ref.invalidate(dnsRecordsProvider(zoneId));
  }

  // Add more mutation methods here later (create, update)
}
