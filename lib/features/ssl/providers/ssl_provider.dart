import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ssl_repository.dart';

final sslModeProvider = FutureProvider.family<String, String>((ref, zoneId) async {
  final repository = ref.watch(sslRepositoryProvider);
  return repository.getSslMode(zoneId);
});
