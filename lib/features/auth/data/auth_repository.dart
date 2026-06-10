import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/account.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(const FlutterSecureStorage());
});

class AuthRepository {
  final FlutterSecureStorage _storage;
  static const _accountsKey = 'cloudflare_accounts';
  static const _activeAccountKey = 'active_account_email';

  AuthRepository(this._storage);

  Future<List<Account>> getAccounts() async {
    final data = await _storage.read(key: _accountsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Account.fromJson(e)).toList();
  }

  Future<void> saveAccount(Account account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.email == account.email);
    if (index >= 0) {
      accounts[index] = account; // Update existing
    } else {
      accounts.add(account);
    }
    await _storage.write(
      key: _accountsKey,
      value: jsonEncode(accounts.map((e) => e.toJson()).toList()),
    );
    await setActiveAccount(account.email);
  }

  Future<void> removeAccount(String email) async {
    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.email == email);
    await _storage.write(
      key: _accountsKey,
      value: jsonEncode(accounts.map((e) => e.toJson()).toList()),
    );

    final activeEmail = await getActiveAccountEmail();
    if (activeEmail == email) {
      if (accounts.isNotEmpty) {
        await setActiveAccount(accounts.first.email);
      } else {
        await _storage.delete(key: _activeAccountKey);
      }
    }
  }

  Future<String?> getActiveAccountEmail() async {
    return await _storage.read(key: _activeAccountKey);
  }

  Future<void> setActiveAccount(String email) async {
    await _storage.write(key: _activeAccountKey, value: email);
  }

  Future<Account?> getActiveAccount() async {
    final activeEmail = await getActiveAccountEmail();
    if (activeEmail == null) return null;
    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((a) => a.email == activeEmail);
    } catch (e) {
      return null;
    }
  }
}
