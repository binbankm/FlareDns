import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/storage_models.dart';
import '../data/storage_repository.dart';

final kvNamespacesProvider = FutureProvider.autoDispose<List<CloudflareKVNamespace>>((ref) async {
  final repository = ref.watch(storageRepositoryProvider);
  return repository.getKVNamespaces();
});

final d1DatabasesProvider = FutureProvider.autoDispose<List<CloudflareD1Database>>((ref) async {
  final repository = ref.watch(storageRepositoryProvider);
  return repository.getD1Databases();
});

final r2BucketsProvider = FutureProvider.autoDispose<List<CloudflareR2Bucket>>((ref) async {
  final repository = ref.watch(storageRepositoryProvider);
  return repository.getR2Buckets();
});
