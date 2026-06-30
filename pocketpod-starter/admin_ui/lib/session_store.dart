import 'package:shared_preferences/shared_preferences.dart';

import 'admin_api.dart';

abstract interface class AdminSessionStore {
  Future<AdminSession?> read();

  Future<void> save(AdminSession session);

  Future<void> clear();
}

class SharedPreferencesAdminSessionStore implements AdminSessionStore {
  static const _tokenKey = 'pocketpod.admin.token';
  static const _userIdKey = 'pocketpod.admin.userId';
  static const _scopeNamesKey = 'pocketpod.admin.scopeNames';

  @override
  Future<AdminSession?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final userId = preferences.getString(_userIdKey);
    final scopeNames = preferences.getStringList(_scopeNamesKey);

    if (token == null || userId == null || scopeNames == null) {
      return null;
    }

    return AdminSession(
      token: token,
      userId: userId,
      scopeNames: scopeNames.toSet(),
    );
  }

  @override
  Future<void> save(AdminSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, session.token);
    await preferences.setString(_userIdKey, session.userId);
    await preferences.setStringList(
      _scopeNamesKey,
      session.scopeNames.toList()..sort(),
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_scopeNamesKey);
  }
}

class MemoryAdminSessionStore implements AdminSessionStore {
  AdminSession? _session;

  @override
  Future<AdminSession?> read() async => _session;

  @override
  Future<void> save(AdminSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}
