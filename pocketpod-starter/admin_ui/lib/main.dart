import 'package:flutter/material.dart';
import 'package:pocketpod_client/pocketpod_client.dart';

import 'admin_api.dart';
import 'session_store.dart';

void main() {
  runApp(const PocketPodAdminApp());
}

class PocketPodAdminApp extends StatelessWidget {
  const PocketPodAdminApp({super.key, this.api, this.sessionStore});

  final AdminApi? api;
  final AdminSessionStore? sessionStore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'PocketPod Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFD9DEE7)),
          ),
        ),
      ),
      home: AdminAuthGate(
        api: api ?? ServerpodAdminApi(),
        sessionStore: sessionStore ?? SharedPreferencesAdminSessionStore(),
      ),
    );
  }
}

class AdminAuthGate extends StatefulWidget {
  const AdminAuthGate({
    required this.api,
    required this.sessionStore,
    super.key,
  });

  final AdminApi api;
  final AdminSessionStore sessionStore;

  @override
  State<AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<AdminAuthGate> {
  AdminSession? _session;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await widget.sessionStore.read();
    if (!mounted) return;

    if (session == null) {
      setState(() => _loading = false);
      return;
    }

    widget.api.setAuthToken(session.token);

    try {
      await widget.api.dashboard();
      if (!mounted) return;
      setState(() {
        _session = session;
        _loading = false;
      });
    } catch (_) {
      await widget.sessionStore.clear();
      widget.api.setAuthToken(null);
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _login(String email, String password) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await widget.api.login(email: email, password: password);
      if (!session.scopeNames.contains('serverpod.admin')) {
        widget.api.setAuthToken(null);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error =
              'Admin access required: signed-in user is missing serverpod.admin scope.';
        });
        return;
      }
      await widget.sessionStore.save(session);
      if (!mounted) return;
      setState(() {
        _session = session;
        _loading = false;
      });
    } catch (error) {
      widget.api.setAuthToken(null);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _adminAuthErrorMessage(error);
      });
    }
  }

  Future<void> _logout() async {
    await widget.sessionStore.clear();
    widget.api.setAuthToken(null);
    if (!mounted) return;
    setState(() {
      _session = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = _session;
    if (session == null) {
      return LoginScreen(error: _error, onSubmit: _login);
    }

    return AdminShell(api: widget.api, session: session, onLogout: _logout);
  }
}

String _adminAuthErrorMessage(Object error) {
  final message = error.toString();
  if (message.contains('Admin scope required') ||
      message.contains('InsufficientAccess') ||
      message.contains('serverpod.admin')) {
    return 'Admin access required: sign in with a Serverpod user that has serverpod.admin scope.';
  }
  return 'Sign in failed: $error';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onSubmit, this.error, super.key});

  final String? error;
  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: 'manual-check@example.com',
  );
  final _passwordController = TextEditingController(text: 'change-me-now');
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'PocketPod Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Serverpod Auth required',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('login_email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('login_password'),
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (widget.error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.error!,
                      key: const Key('login_error'),
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    key: const Key('login_submit'),
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Signing in...' : 'Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({
    required this.api,
    required this.session,
    required this.onLogout,
    super.key,
  });

  final AdminApi api;
  final AdminSession session;
  final Future<void> Function() onLogout;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  List<AdminCollection> _collections = const [];
  AdminCollection? _activeCollection;
  List<AdminRecord> _records = const [];
  AdminRecord? _selectedRecord;
  Map<String, List<AdminRecordCell>> _relationOptions = const {};
  int _recordOffset = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  bool _loadingCollections = true;
  bool _loadingRecords = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() {
      _loadingCollections = true;
      _error = null;
    });

    try {
      final collections = await widget.api.listCollections();
      if (!mounted) return;
      setState(() {
        _collections = collections;
        _activeCollection = collections.isEmpty ? null : collections.first;
        _loadingCollections = false;
      });
      final active = _activeCollection;
      if (active != null) {
        await _selectCollection(active);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingCollections = false;
        _error = 'Collection load failed: $error';
      });
    }
  }

  Future<void> _selectCollection(AdminCollection collection) async {
    setState(() {
      _activeCollection = collection;
      _selectedRecord = null;
      _relationOptions = const {};
      _recordOffset = 0;
      _searchQuery = '';
      _loadingRecords = true;
      _error = null;
    });

    await _loadRelationOptions(collection);
    await _loadRecords(collection);
  }

  Future<void> _loadRecords(AdminCollection collection) async {
    setState(() {
      _loadingRecords = true;
      _error = null;
    });

    try {
      final response = await widget.api.listRecords(
        collection.key,
        offset: _recordOffset,
        limit: _pageSize,
        query: _searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _activeCollection = response.collection;
        _records = response.rows;
        _loadingRecords = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingRecords = false;
        _error = 'Record load failed: $error';
      });
    }
  }

  Future<void> _loadRelationOptions(AdminCollection collection) async {
    final relationFields = collection.fields.where(
      (field) => field.control == 'relation',
    );
    if (relationFields.isEmpty) {
      return;
    }

    final loaded = <String, List<AdminRecordCell>>{};
    for (final field in relationFields) {
      loaded[field.name] = await widget.api.relationOptions(
        collection.key,
        field.name,
      );
    }
    if (!mounted) return;
    setState(() => _relationOptions = loaded);
  }

  Future<void> _searchRecords(String query) async {
    final collection = _activeCollection;
    if (collection == null) return;
    setState(() {
      _searchQuery = query.trim();
      _recordOffset = 0;
      _selectedRecord = null;
    });
    await _loadRecords(collection);
  }

  Future<void> _changePageSize(int pageSize) async {
    final collection = _activeCollection;
    if (collection == null) return;
    setState(() {
      _pageSize = pageSize;
      _recordOffset = 0;
      _selectedRecord = null;
    });
    await _loadRecords(collection);
  }

  Future<void> _previousPage() async {
    final collection = _activeCollection;
    if (collection == null || _recordOffset == 0) return;
    setState(() {
      _recordOffset = (_recordOffset - _pageSize)
          .clamp(0, _recordOffset)
          .toInt();
      _selectedRecord = null;
    });
    await _loadRecords(collection);
  }

  Future<void> _nextPage() async {
    final collection = _activeCollection;
    if (collection == null) return;
    final total = collection.rowCount;
    if (_recordOffset + _pageSize >= total) return;
    setState(() {
      _recordOffset += _pageSize;
      _selectedRecord = null;
    });
    await _loadRecords(collection);
  }

  Future<void> _openRecord(AdminRecord record) async {
    final collection = _activeCollection;
    if (collection == null) return;

    setState(() {
      _selectedRecord = null;
      _error = null;
    });

    try {
      final loaded = await widget.api.getRecord(collection.key, record.id);
      if (!mounted) return;
      setState(() => _selectedRecord = loaded);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Record open failed: $error');
    }
  }

  Future<AdminRecord> _saveRecord(AdminRecord record) async {
    final collection = _activeCollection;
    if (collection == null) {
      throw StateError('No active collection.');
    }

    final creating = record.id.isEmpty;
    final saved = creating
        ? await widget.api.createRecord(collection.key, record.cells)
        : await widget.api.updateRecord(
            collection.key,
            record.id,
            record.cells,
          );
    if (!mounted) return saved;

    setState(() {
      _selectedRecord = saved;
      _records = creating
          ? [..._records, saved]
          : [
              for (final row in _records)
                if (row.id == saved.id) saved else row,
            ];
      _activeCollection = collection.copyWith(
        rowCount: creating ? collection.rowCount + 1 : collection.rowCount,
      );
      _collections = [
        for (final item in _collections)
          if (item.key == collection.key) _activeCollection! else item,
      ];
      _error = null;
    });

    return saved;
  }

  void _newRecord() {
    final collection = _activeCollection;
    if (collection == null || !isEditableCollection(collection.key)) {
      return;
    }

    setState(() {
      _selectedRecord = AdminRecord(
        id: '',
        cells: [
          for (final field in collection.fields)
            AdminRecordCell(
              field: field.name,
              value: defaultValueForField(field),
            ),
        ],
      );
      _error = null;
    });
  }

  Future<void> _deleteRecord(AdminRecord record) async {
    final collection = _activeCollection;
    if (collection == null || record.id.isEmpty) {
      return;
    }

    try {
      await widget.api.deleteRecord(collection.key, record.id);
      if (!mounted) return;
      setState(() {
        _records = [
          for (final row in _records)
            if (row.id != record.id) row,
        ];
        _selectedRecord = null;
        _activeCollection = collection.copyWith(
          rowCount: collection.rowCount > 0 ? collection.rowCount - 1 : 0,
        );
        _collections = [
          for (final item in _collections)
            if (item.key == collection.key) _activeCollection! else item,
        ];
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Delete failed: $error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FocusTraversalGroup(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 820;
              final sidebar = AdminSidebar(
                collections: _collections,
                activeCollection: _activeCollection,
                loading: _loadingCollections,
                compact: narrow,
                onSelect: _selectCollection,
              );
              final workspace = AdminWorkspace(
                session: widget.session,
                collections: _collections,
                activeCollection: _activeCollection,
                records: _records,
                selectedRecord: _selectedRecord,
                loadingRecords: _loadingRecords,
                error: _error,
                relationOptions: _relationOptions,
                recordOffset: _recordOffset,
                pageSize: _pageSize,
                searchQuery: _searchQuery,
                onOpenRecord: _openRecord,
                onNewRecord: _newRecord,
                onSaveRecord: _saveRecord,
                onDeleteRecord: _deleteRecord,
                onSearchRecords: _searchRecords,
                onChangePageSize: _changePageSize,
                onPreviousPage: _previousPage,
                onNextPage: _nextPage,
                onLogout: widget.onLogout,
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 220, child: sidebar),
                    Expanded(child: workspace),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sidebar,
                  Expanded(child: workspace),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    required this.collections,
    required this.activeCollection,
    required this.loading,
    required this.onSelect,
    this.compact = false,
    super.key,
  });

  final List<AdminCollection> collections;
  final AdminCollection? activeCollection;
  final bool loading;
  final ValueChanged<AdminCollection> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 260,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        border: Border(
          right: compact
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFD9DEE7)),
          bottom: compact
              ? const BorderSide(color: Color(0xFFD9DEE7))
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PocketPod',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Flutter Admin',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: compact ? 16 : 28),
            const _NavLabel('Collections'),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              )
            else
              for (final collection in collections)
                _CollectionNavItem(
                  label: collection.title,
                  count: collection.rowCount,
                  selected: collection.key == activeCollection?.key,
                  onTap: () => onSelect(collection),
                ),
            if (!compact) const SizedBox(height: 28),
            const _NavLabel('System'),
            const _CollectionNavItem(label: 'Auth', count: 1),
          ],
        ),
      ),
    );
  }
}

class AdminWorkspace extends StatelessWidget {
  const AdminWorkspace({
    required this.session,
    required this.collections,
    required this.activeCollection,
    required this.records,
    required this.selectedRecord,
    required this.loadingRecords,
    required this.relationOptions,
    required this.recordOffset,
    required this.pageSize,
    required this.searchQuery,
    required this.onOpenRecord,
    required this.onNewRecord,
    required this.onSaveRecord,
    required this.onDeleteRecord,
    required this.onSearchRecords,
    required this.onChangePageSize,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onLogout,
    this.error,
    super.key,
  });

  final AdminSession session;
  final List<AdminCollection> collections;
  final AdminCollection? activeCollection;
  final List<AdminRecord> records;
  final AdminRecord? selectedRecord;
  final bool loadingRecords;
  final String? error;
  final Map<String, List<AdminRecordCell>> relationOptions;
  final int recordOffset;
  final int pageSize;
  final String searchQuery;
  final ValueChanged<AdminRecord> onOpenRecord;
  final VoidCallback onNewRecord;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;
  final Future<void> Function(AdminRecord record) onDeleteRecord;
  final ValueChanged<String> onSearchRecords;
  final ValueChanged<int> onChangePageSize;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final activeCollection = this.activeCollection;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        return Padding(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WorkspaceTitle(session: session, compact: true),
                    const SizedBox(height: 12),
                    _SignOutButton(onLogout: onLogout),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _WorkspaceTitle(session: session)),
                    _SignOutButton(onLogout: onLogout),
                  ],
                ),
              const SizedBox(height: 20),
              _MetricStrip(
                session: session,
                collectionCount: collections.length,
              ),
              const SizedBox(height: 18),
              if (error != null) ...[
                _ErrorBanner(error!),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: activeCollection == null
                    ? const _EmptyPanel(message: 'No collections available.')
                    : _CollectionPanel(
                        collection: activeCollection,
                        records: records,
                        selectedRecord: selectedRecord,
                        loading: loadingRecords,
                        relationOptions: relationOptions,
                        recordOffset: recordOffset,
                        pageSize: pageSize,
                        searchQuery: searchQuery,
                        onOpenRecord: onOpenRecord,
                        onNewRecord: onNewRecord,
                        onSaveRecord: onSaveRecord,
                        onDeleteRecord: onDeleteRecord,
                        onSearchRecords: onSearchRecords,
                        onChangePageSize: onChangePageSize,
                        onPreviousPage: onPreviousPage,
                        onNextPage: onNextPage,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceTitle extends StatelessWidget {
  const _WorkspaceTitle({required this.session, this.compact = false});

  final AdminSession session;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          compact ? 'PocketPod\nAdmin' : 'PocketPod Admin',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: compact ? 1.05 : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          compact ? 'Signed in' : 'Signed in as ${session.userId}',
          key: const Key('admin_status_line'),
          softWrap: true,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign out of PocketPod Admin',
      child: OutlinedButton(
        key: const Key('logout_button'),
        onPressed: onLogout,
        child: const Text('Sign out'),
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.session, required this.collectionCount});

  final AdminSession session;
  final int collectionCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 640
            ? constraints.maxWidth
            : (constraints.maxWidth - 28) / 3;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(label: 'Auth', value: 'Serverpod'),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                label: 'Collections',
                value: '$collectionCount',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                label: 'Scopes',
                value: session.scopeNames.join(', '),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CollectionPanel extends StatelessWidget {
  const _CollectionPanel({
    required this.collection,
    required this.records,
    required this.selectedRecord,
    required this.loading,
    required this.relationOptions,
    required this.recordOffset,
    required this.pageSize,
    required this.searchQuery,
    required this.onOpenRecord,
    required this.onNewRecord,
    required this.onSaveRecord,
    required this.onDeleteRecord,
    required this.onSearchRecords,
    required this.onChangePageSize,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final AdminCollection collection;
  final List<AdminRecord> records;
  final AdminRecord? selectedRecord;
  final bool loading;
  final Map<String, List<AdminRecordCell>> relationOptions;
  final int recordOffset;
  final int pageSize;
  final String searchQuery;
  final ValueChanged<AdminRecord> onOpenRecord;
  final VoidCallback onNewRecord;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;
  final Future<void> Function(AdminRecord record) onDeleteRecord;
  final ValueChanged<String> onSearchRecords;
  final ValueChanged<int> onChangePageSize;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFD9DEE7))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          collection.title,
                          key: const Key('active_collection_title'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isEditableCollection(collection.key))
                        FilledButton.icon(
                          key: const Key('new_record'),
                          onPressed: onNewRecord,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collection.description,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final field in collection.fields)
                    _FieldChip(
                      '${field.label}${field.required ? ' *' : ''} / ${field.control}',
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            _TableControls(
              collection: collection,
              offset: recordOffset,
              pageSize: pageSize,
              searchQuery: searchQuery,
              onSearchRecords: onSearchRecords,
              onChangePageSize: onChangePageSize,
              onPreviousPage: onPreviousPage,
              onNextPage: onNextPage,
            ),
            loading
                ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _RecordsTable(
                    collection: collection,
                    records: records,
                    onOpenRecord: onOpenRecord,
                  ),
            if (selectedRecord != null)
              _RecordDetail(
                collection: collection,
                record: selectedRecord!,
                relationOptions: relationOptions,
                onSaveRecord: onSaveRecord,
                onDeleteRecord: onDeleteRecord,
              ),
          ],
        ),
      ),
    );
  }
}

class _TableControls extends StatefulWidget {
  const _TableControls({
    required this.collection,
    required this.offset,
    required this.pageSize,
    required this.searchQuery,
    required this.onSearchRecords,
    required this.onChangePageSize,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final AdminCollection collection;
  final int offset;
  final int pageSize;
  final String searchQuery;
  final ValueChanged<String> onSearchRecords;
  final ValueChanged<int> onChangePageSize;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  @override
  State<_TableControls> createState() => _TableControlsState();
}

class _TableControlsState extends State<_TableControls> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _TableControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.collection.rowCount == 0 ? 0 : widget.offset + 1;
    final end = (widget.offset + widget.pageSize).clamp(
      0,
      widget.collection.rowCount,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              key: const Key('record_search'),
              controller: _searchController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Search',
              ),
              onSubmitted: widget.onSearchRecords,
            ),
          ),
          FilledButton.tonal(
            key: const Key('apply_search'),
            onPressed: () => widget.onSearchRecords(_searchController.text),
            child: const Text('Search'),
          ),
          DropdownButton<int>(
            key: const Key('page_size'),
            value: widget.pageSize,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10')),
              DropdownMenuItem(value: 25, child: Text('25')),
              DropdownMenuItem(value: 50, child: Text('50')),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onChangePageSize(value);
              }
            },
          ),
          Text('$start-$end of ${widget.collection.rowCount}'),
          IconButton(
            key: const Key('previous_page'),
            tooltip: 'Previous page',
            onPressed: widget.offset == 0 ? null : widget.onPreviousPage,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            key: const Key('next_page'),
            tooltip: 'Next page',
            onPressed:
                widget.offset + widget.pageSize >= widget.collection.rowCount
                ? null
                : widget.onNextPage,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _RecordsTable extends StatelessWidget {
  const _RecordsTable({
    required this.collection,
    required this.records,
    required this.onOpenRecord,
  });

  final AdminCollection collection;
  final List<AdminRecord> records;
  final ValueChanged<AdminRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No records in this collection yet.')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('ID')),
          for (final field in collection.fields)
            DataColumn(label: Text(field.label)),
          const DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final record in records)
            DataRow(
              cells: [
                DataCell(Text(record.id)),
                for (final field in collection.fields)
                  DataCell(
                    _RecordCell(
                      collection: collection,
                      record: record,
                      field: field,
                      onOpenRecord: onOpenRecord,
                    ),
                  ),
                DataCell(
                  TextButton(
                    onPressed: isEditableCollection(collection.key)
                        ? () => onOpenRecord(record)
                        : null,
                    child: Text(
                      isEditableCollection(collection.key)
                          ? 'Edit'
                          : 'Read-only',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RecordCell extends StatelessWidget {
  const _RecordCell({
    required this.collection,
    required this.record,
    required this.field,
    required this.onOpenRecord,
  });

  final AdminCollection collection;
  final AdminRecord record;
  final AdminField field;
  final ValueChanged<AdminRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final value = record.valueFor(field.name);
    if (field.name == primaryEditField(collection.key)) {
      return TextButton(
        key: Key('primary_${collection.key}_${record.id}'),
        onPressed: () => onOpenRecord(record),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }
    return Text(value, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class _RecordDetail extends StatefulWidget {
  const _RecordDetail({
    required this.collection,
    required this.record,
    required this.relationOptions,
    required this.onSaveRecord,
    required this.onDeleteRecord,
  });

  final AdminCollection collection;
  final AdminRecord record;
  final Map<String, List<AdminRecordCell>> relationOptions;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;
  final Future<void> Function(AdminRecord record) onDeleteRecord;

  @override
  State<_RecordDetail> createState() => _RecordDetailState();
}

class _RecordDetailState extends State<_RecordDetail> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolValues = {};
  String? _message;
  String? _error;
  bool _saving = false;
  bool _deleting = false;

  bool get _editable => isEditableCollection(widget.collection.key);
  bool get _creating => widget.record.id.isEmpty;

  @override
  void initState() {
    super.initState();
    _hydrate(widget.record);
  }

  @override
  void didUpdateWidget(covariant _RecordDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id ||
        oldWidget.collection.key != widget.collection.key) {
      _hydrate(widget.record);
      if (oldWidget.collection.key != widget.collection.key ||
          oldWidget.record.id.isNotEmpty) {
        _message = null;
        _error = null;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _hydrate(AdminRecord record) {
    final currentFields = widget.collection.fields
        .map((field) => field.name)
        .toSet();
    for (final entry in _controllers.entries.toList()) {
      if (!currentFields.contains(entry.key)) {
        entry.value.dispose();
        _controllers.remove(entry.key);
      }
    }

    for (final field in widget.collection.fields) {
      final value = record.valueFor(field.name);
      if (field.control == 'checkbox') {
        _boolValues[field.name] = value.toLowerCase() == 'true';
      } else {
        final controller = _controllers.putIfAbsent(
          field.name,
          () => TextEditingController(),
        );
        controller.text = value;
      }
    }
  }

  Future<void> _save() async {
    if (!_editable || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
      _error = null;
    });

    final cells = [
      for (final field in widget.collection.fields)
        AdminRecordCell(field: field.name, value: _valueFor(field)),
    ];

    try {
      final saved = await widget.onSaveRecord(
        AdminRecord(id: widget.record.id, cells: cells),
      );
      if (!mounted) return;
      _hydrate(saved);
      setState(() {
        _saving = false;
        _message = _creating
            ? '${widget.collection.title} #${saved.id} created.'
            : '${widget.collection.title} #${saved.id} saved.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Save failed: $error';
      });
    }
  }

  Future<void> _delete() async {
    if (!_editable || _creating) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.collection.title} #${widget.record.id}?'),
        content: const Text('This action removes the record from SQLite.'),
        actions: [
          TextButton(
            key: const Key('cancel_delete'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
      _message = null;
      _error = null;
    });

    try {
      await widget.onDeleteRecord(widget.record);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = 'Delete failed: $error';
      });
    }
  }

  String _valueFor(AdminField field) {
    if (field.control == 'checkbox') {
      return (_boolValues[field.name] ?? false).toString();
    }
    return _controllers[field.name]?.text.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('record_detail'),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFD),
        border: Border(top: BorderSide(color: Color(0xFFD9DEE7))),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _detailTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 720;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final field in widget.collection.fields)
                      SizedBox(
                        width: twoColumns ? 320 : constraints.maxWidth,
                        child: _AdminFieldControl(
                          key: Key('field_${field.name}'),
                          field: field,
                          controller: _controllers[field.name],
                          boolValue: _boolValues[field.name] ?? false,
                          options:
                              widget.relationOptions[field.name] ?? const [],
                          readOnly: !_editable || field.name == 'updatedAt',
                          onBoolChanged: (value) {
                            setState(() {
                              _boolValues[field.name] = value ?? false;
                            });
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Text(
                _message!,
                key: const Key('save_success'),
                style: const TextStyle(
                  color: Color(0xFF047857),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                key: const Key('save_error'),
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_editable)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    key: const Key('save_record'),
                    onPressed: _saving || _deleting ? null : _save,
                    child: Text(
                      _saving
                          ? 'Saving...'
                          : _creating
                          ? 'Create record'
                          : 'Save changes',
                    ),
                  ),
                  if (!_creating)
                    OutlinedButton(
                      key: const Key('delete_record'),
                      onPressed: _saving || _deleting ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB42318),
                      ),
                      child: Text(_deleting ? 'Deleting...' : 'Delete'),
                    ),
                ],
              )
            else
              const Text(
                'This demo collection is read-only.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
          ],
        ),
      ),
    );
  }

  String get _detailTitle {
    if (!_editable) {
      return 'View ${widget.collection.title} #${widget.record.id}';
    }
    if (_creating) {
      return 'Create ${widget.collection.title}';
    }
    return 'Edit ${widget.collection.title} #${widget.record.id}';
  }
}

class _AdminFieldControl extends StatelessWidget {
  const _AdminFieldControl({
    required this.field,
    required this.readOnly,
    required this.boolValue,
    required this.options,
    required this.onBoolChanged,
    this.controller,
    super.key,
  });

  final AdminField field;
  final TextEditingController? controller;
  final bool readOnly;
  final bool boolValue;
  final List<AdminRecordCell> options;
  final ValueChanged<bool?> onBoolChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(field: field),
        const SizedBox(height: 6),
        _buildControl(context),
      ],
    );
  }

  Widget _buildControl(BuildContext context) {
    return switch (field.control) {
      'textarea' => TextFormField(
        key: Key('input_${field.name}'),
        controller: controller,
        enabled: !readOnly,
        maxLines: 5,
        validator: _requiredValidator,
        decoration: _decoration(),
      ),
      'checkbox' => CheckboxListTile(
        key: Key('input_${field.name}'),
        value: boolValue,
        onChanged: readOnly ? null : onBoolChanged,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Enabled'),
      ),
      'datetime' => TextFormField(
        key: Key('input_${field.name}'),
        controller: controller,
        enabled: !readOnly,
        readOnly: true,
        validator: _requiredValidator,
        decoration: _decoration(
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        onTap: readOnly ? null : () => _pickDateTime(context),
      ),
      'number' => TextFormField(
        key: Key('input_${field.name}'),
        controller: controller,
        enabled: !readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: _numberValidator,
        decoration: _decoration(),
      ),
      'select' || 'relation' => DropdownButtonFormField<String>(
        key: Key('input_${field.name}'),
        initialValue: _dropdownValue,
        items: [
          for (final option in _options)
            DropdownMenuItem(value: option.field, child: Text(option.value)),
        ],
        onChanged: readOnly
            ? null
            : (value) {
                if (value != null) {
                  controller?.text = value;
                }
              },
        validator: _requiredValidator,
        decoration: _decoration(),
      ),
      _ => TextFormField(
        key: Key('input_${field.name}'),
        controller: controller,
        enabled: !readOnly,
        validator: _requiredValidator,
        decoration: _decoration(),
      ),
    };
  }

  String? _requiredValidator(String? value) {
    if (field.required && (value == null || value.trim().isEmpty)) {
      return '${field.label} is required.';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (value == null || value.trim().isEmpty) return null;
    if (num.tryParse(value.trim()) == null) {
      return '${field.label} must be numeric.';
    }
    return null;
  }

  InputDecoration _decoration({Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
      suffixIcon: suffixIcon,
    );
  }

  String? get _dropdownValue {
    final value = controller?.text.trim() ?? '';
    if (value.isEmpty) return null;
    return _options.any((option) => option.field == value)
        ? value
        : _options.first.field;
  }

  List<AdminRecordCell> get _options {
    final current = controller?.text.trim() ?? '';
    final baseOptions = switch (field.name) {
      'status' => [
        AdminRecordCell(field: 'draft', value: 'Draft'),
        AdminRecordCell(field: 'published', value: 'Published'),
        AdminRecordCell(field: 'archived', value: 'Archived'),
      ],
      _ => options,
    };
    return [
      if (current.isNotEmpty &&
          !baseOptions.any((option) => option.field == current))
        AdminRecordCell(field: current, value: current),
      ...baseOptions,
    ];
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _initialDate ?? now,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_initialDate ?? now),
    );
    if (time == null) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
    controller?.text = picked.toIso8601String();
  }

  DateTime? get _initialDate {
    final value = controller?.text.trim() ?? '';
    return value.isEmpty ? null : DateTime.tryParse(value)?.toLocal();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.field});

  final AdminField field;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(text: field.label),
          if (field.required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFB42318)),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDA29B)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(child: Center(child: Text(message)));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionNavItem extends StatelessWidget {
  const _CollectionNavItem({
    required this.label,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFD7F4EF) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        key: Key('nav_$label'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF064E47)
                        : const Color(0xFF374151),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              Text('$count', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

bool isEditableCollection(String key) => key == 'products' || key == 'posts';

String defaultValueForField(AdminField field) {
  if (field.name == 'updatedAt') {
    return DateTime.now().toUtc().toIso8601String();
  }
  return switch (field.control) {
    'checkbox' => 'false',
    'number' when field.dartType == 'double' => '0.00',
    'number' => '0',
    'relation' => '1',
    'datetime' => '',
    _ => '',
  };
}

String? primaryEditField(String key) {
  return switch (key) {
    'products' => 'name',
    'posts' || 'admin_input_examples' => 'title',
    _ => null,
  };
}

extension on AdminRecord {
  String valueFor(String fieldName) {
    for (final cell in cells) {
      if (cell.field == fieldName) {
        return cell.value;
      }
    }
    return '';
  }
}
