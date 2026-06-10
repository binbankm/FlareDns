import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/page.dart';
import '../data/pages_repository.dart';

final pagesProvider = FutureProvider.autoDispose<List<CloudflarePage>>((
  ref,
) async {
  return ref.watch(pagesRepositoryProvider).getPages();
});

final pageDeploymentsProvider = FutureProvider.autoDispose
    .family<List<PageDeployment>, String>((ref, projectName) async {
      return ref.watch(pagesRepositoryProvider).getDeployments(projectName);
    });

final pageDomainsProvider = FutureProvider.autoDispose
    .family<List<PageDomain>, String>((ref, projectName) async {
      return ref.watch(pagesRepositoryProvider).getDomains(projectName);
    });

final pageProjectProvider = FutureProvider.autoDispose
    .family<CloudflarePage, String>((ref, projectName) async {
      return ref.watch(pagesRepositoryProvider).getProject(projectName);
    });
