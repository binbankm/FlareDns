import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/account.dart';
import '../data/auth_repository.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Account?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<Account?> {
  @override
  Future<Account?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.getActiveAccount();
  }

  Future<void> login(String email, String apiKey) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final account = Account(email: email, apiKey: apiKey);
      await repository.saveAccount(account);
      return account;
    });
  }

  Future<void> logout() async {
    final current = state.value;
    if (current != null) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(authRepositoryProvider);
        await repository.removeAccount(current.email);
        return repository.getActiveAccount();
      });
    }
  }

  Future<void> switchAccount(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.setActiveAccount(email);
      return repository.getActiveAccount();
    });
  }
}
