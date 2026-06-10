import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/worker.dart';
import '../data/workers_repository.dart';

final workersProvider = FutureProvider.autoDispose<List<CloudflareWorker>>((ref) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getWorkers();
});

final workerBindingsProvider = FutureProvider.autoDispose.family<List<WorkerBinding>, String>((ref, scriptName) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getBindings(scriptName);
});

final workerSchedulesProvider = FutureProvider.autoDispose.family<List<WorkerSchedule>, String>((ref, scriptName) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getSchedules(scriptName);
});

final workerContentProvider = FutureProvider.autoDispose.family<String, String>((ref, scriptName) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getWorkerContent(scriptName);
});

final workerDeploymentsProvider = FutureProvider.autoDispose.family<List<WorkerDeployment>, String>((ref, scriptName) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getDeployments(scriptName);
});

final workerDomainsProvider = FutureProvider.autoDispose<List<WorkerDomain>>((ref) async {
  final repo = ref.read(workersRepositoryProvider);
  return repo.getDomains();
});

final kvNamespacesProvider = FutureProvider.autoDispose<List<CloudflareKVNamespace>>((ref) async {
  final repo = ref.read(workersRepositoryProvider);
  return repo.getKVNamespaces();
});

final d1DatabasesProvider = FutureProvider.autoDispose<List<CloudflareD1Database>>((ref) async {
  final repo = ref.read(workersRepositoryProvider);
  return repo.getD1Databases();
});

final workerSecretsProvider = FutureProvider.autoDispose.family<List<WorkerSecret>, String>((ref, scriptName) async {
  final repository = ref.watch(workersRepositoryProvider);
  return repository.getSecrets(scriptName);
});
