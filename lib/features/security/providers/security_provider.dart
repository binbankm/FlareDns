import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/security_repository.dart';

final devModeProvider = FutureProvider.family<bool, String>((
  ref,
  zoneId,
) async {
  final repo = ref.watch(securityRepositoryProvider);
  final mode = await repo.getDevelopmentMode(zoneId);
  return mode == 'on';
});

final securityLevelProvider = FutureProvider.family<String, String>((
  ref,
  zoneId,
) async {
  final repo = ref.watch(securityRepositoryProvider);
  return await repo.getSecurityLevel(zoneId);
});
