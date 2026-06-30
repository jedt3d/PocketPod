// ignore_for_file: deprecated_member_use

import 'package:pocketpod_client/pocketpod_client.dart';

class AdminSession {
  const AdminSession({
    required this.token,
    required this.userId,
    required this.scopeNames,
  });

  final String token;
  final String userId;
  final Set<String> scopeNames;
}

abstract interface class AdminApi {
  void setAuthToken(String? token);

  Future<AdminSession> login({required String email, required String password});

  Future<AdminDashboard> dashboard();

  Future<List<AdminCollection>> listCollections();

  Future<AdminCollectionRecords> listRecords(String collectionKey);

  Future<AdminRecord> getRecord(String collectionKey, String id);

  Future<AdminRecord> updateRecord(
    String collectionKey,
    String id,
    List<AdminRecordCell> cells,
  );
}

class ServerpodAdminApi implements AdminApi {
  ServerpodAdminApi({
    String serverUrl = 'http://localhost:8080/',
    MutableBearerAuthenticationKeyManager? authKeyManager,
  }) : this._(
         serverUrl,
         authKeyManager ?? MutableBearerAuthenticationKeyManager(),
       );

  ServerpodAdminApi._(
    String serverUrl,
    MutableBearerAuthenticationKeyManager authKeyManager,
  ) : _authKeyManager = authKeyManager,
      _client = Client(serverUrl, authenticationKeyManager: authKeyManager);

  final MutableBearerAuthenticationKeyManager _authKeyManager;
  final Client _client;

  @override
  void setAuthToken(String? token) {
    _authKeyManager.setToken(token);
  }

  @override
  Future<AdminSession> login({
    required String email,
    required String password,
  }) async {
    final auth = await _client.adminAuth.login(
      email: email,
      password: password,
    );
    _authKeyManager.setToken(auth.token);
    return AdminSession(
      token: auth.token,
      userId: auth.authUserId.toString(),
      scopeNames: auth.scopeNames,
    );
  }

  @override
  Future<AdminDashboard> dashboard() {
    return _client.admin.dashboard();
  }

  @override
  Future<List<AdminCollection>> listCollections() {
    return _client.admin.listCollections();
  }

  @override
  Future<AdminCollectionRecords> listRecords(String collectionKey) {
    return _client.admin.listRecords(collectionKey);
  }

  @override
  Future<AdminRecord> getRecord(String collectionKey, String id) {
    return _client.admin.getRecord(collectionKey, id);
  }

  @override
  Future<AdminRecord> updateRecord(
    String collectionKey,
    String id,
    List<AdminRecordCell> cells,
  ) {
    return _client.admin.updateRecord(collectionKey, id, cells);
  }
}

class MutableBearerAuthenticationKeyManager extends AuthenticationKeyManager {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  @override
  Future<String?> get() async => _token;

  @override
  Future<void> put(String key) async {
    _token = key;
  }

  @override
  Future<void> remove() async {
    _token = null;
  }

  @override
  Future<String?> toHeaderValue(String? key) async {
    if (key == null || key.isEmpty) {
      return null;
    }
    return wrapAsBearerAuthHeaderValue(key);
  }
}
