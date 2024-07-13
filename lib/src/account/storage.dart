import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

/// Allows to load and store accounts
class AccountStorage {
  /// Creates a new [AccountStorage]
  const AccountStorage();

  static const String _keyAccounts = 'accts';
  static const String _keyFirstRun = 'firstRun';
  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  /// Loads the accounts from the storage
  Future<List<RealAccount>> loadAccounts() async {
    // on iOS the key chain keeps all data even after the app is uninstalled
    // so we need to delete all data if the app is started for the first time
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final preferences = await SharedPreferences.getInstance();
      if (preferences.getBool(_keyFirstRun) ?? true) {
        const FlutterSecureStorage storage = FlutterSecureStorage();
        await storage.deleteAll();
        await preferences.setBool(_keyFirstRun, false);
      }
    }

    final jsonText = await _storage.read(key: _keyAccounts);
    if (jsonText == null) {
      return <RealAccount>[];
    }
    final accountsJson = jsonDecode(jsonText) as List;
    try {
      // ignore: unnecessary_lambdas
      return accountsJson.map((json) => RealAccount.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Unable to parse accounts: $e');
        print(jsonText);
      }

      return <RealAccount>[];
    }
  }

  /// Saves the given [accounts] to the storage
  Future<void> saveAccounts(List<Account> accounts) {
    final accountsJson =
        accounts.whereType<RealAccount>().map((a) => a.toJson()).toList();
    final json = jsonEncode(accountsJson);

    return _storage.write(key: _keyAccounts, value: json);
  }
}
