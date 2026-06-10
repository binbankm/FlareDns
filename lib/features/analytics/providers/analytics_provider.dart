import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_repository.dart';

final analyticsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  zoneId,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return await repo.getDashboardMetrics(zoneId);
});
