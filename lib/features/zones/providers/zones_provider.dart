import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/zone.dart';
import '../data/zones_repository.dart';

final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repository = ref.watch(zonesRepositoryProvider);
  return repository.getZones();
});

final zoneSslCertificatesProvider = FutureProvider.family<List<dynamic>, String>((ref, zoneId) async {
  final repository = ref.watch(zonesRepositoryProvider);
  return repository.getSslCertificates(zoneId);
});
