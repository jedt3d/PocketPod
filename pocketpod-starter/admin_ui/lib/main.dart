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
        _error = 'Sign in failed: $error';
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
      _loadingRecords = true;
      _error = null;
    });

    try {
      final response = await widget.api.listRecords(collection.key);
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

    final saved = await widget.api.updateRecord(
      collection.key,
      record.id,
      record.cells,
    );
    if (!mounted) return saved;

    setState(() {
      _selectedRecord = saved;
      _records = [
        for (final row in _records)
          if (row.id == saved.id) saved else row,
      ];
      _error = null;
    });

    return saved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminSidebar(
              collections: _collections,
              activeCollection: _activeCollection,
              loading: _loadingCollections,
              onSelect: _selectCollection,
            ),
            Expanded(
              child: AdminWorkspace(
                session: widget.session,
                collections: _collections,
                activeCollection: _activeCollection,
                records: _records,
                selectedRecord: _selectedRecord,
                loadingRecords: _loadingRecords,
                error: _error,
                onOpenRecord: _openRecord,
                onSaveRecord: _saveRecord,
                onLogout: widget.onLogout,
              ),
            ),
          ],
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
    super.key,
  });

  final List<AdminCollection> collections;
  final AdminCollection? activeCollection;
  final bool loading;
  final ValueChanged<AdminCollection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2F6),
        border: Border(right: BorderSide(color: Color(0xFFD9DEE7))),
      ),
      padding: const EdgeInsets.all(18),
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
          const SizedBox(height: 28),
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
          const Spacer(),
          const _NavLabel('System'),
          const _CollectionNavItem(label: 'Auth', count: 1),
        ],
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
    required this.onOpenRecord,
    required this.onSaveRecord,
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
  final ValueChanged<AdminRecord> onOpenRecord;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final activeCollection = this.activeCollection;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PocketPod Admin',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Signed in as ${session.userId}',
                      key: const Key('admin_status_line'),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                key: const Key('logout_button'),
                onPressed: onLogout,
                child: const Text('Sign out'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricStrip(session: session, collectionCount: collections.length),
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
                    onOpenRecord: onOpenRecord,
                    onSaveRecord: onSaveRecord,
                  ),
          ),
        ],
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
    return Row(
      children: [
        const Expanded(
          child: _MetricCard(label: 'Auth', value: 'Serverpod'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _MetricCard(label: 'Collections', value: '$collectionCount'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _MetricCard(
            label: 'Scopes',
            value: session.scopeNames.join(', '),
          ),
        ),
      ],
    );
  }
}

class _CollectionPanel extends StatelessWidget {
  const _CollectionPanel({
    required this.collection,
    required this.records,
    required this.selectedRecord,
    required this.loading,
    required this.onOpenRecord,
    required this.onSaveRecord,
  });

  final AdminCollection collection;
  final List<AdminRecord> records;
  final AdminRecord? selectedRecord;
  final bool loading;
  final ValueChanged<AdminRecord> onOpenRecord;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;

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
                  Text(
                    collection.title,
                    key: const Key('active_collection_title'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                onSaveRecord: onSaveRecord,
              ),
          ],
        ),
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
    required this.onSaveRecord,
  });

  final AdminCollection collection;
  final AdminRecord record;
  final Future<AdminRecord> Function(AdminRecord record) onSaveRecord;

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

  bool get _editable => isEditableCollection(widget.collection.key);

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
      _message = null;
      _error = null;
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
        _message = '${widget.collection.title} #${saved.id} saved.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Save failed: $error';
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
              '${_editable ? 'Edit' : 'View'} ${widget.collection.title} #${widget.record.id}',
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
              FilledButton(
                key: const Key('save_record'),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save changes'),
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
}

class _AdminFieldControl extends StatelessWidget {
  const _AdminFieldControl({
    required this.field,
    required this.readOnly,
    required this.boolValue,
    required this.onBoolChanged,
    this.controller,
    super.key,
  });

  final AdminField field;
  final TextEditingController? controller;
  final bool readOnly;
  final bool boolValue;
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
            DropdownMenuItem(value: option, child: Text(option)),
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
    return _options.contains(value) ? value : _options.first;
  }

  List<String> get _options {
    final current = controller?.text.trim() ?? '';
    final options = switch (field.name) {
      'status' => ['draft', 'published', 'archived'],
      'categoryId' || 'authorId' => ['1', '2', '3'],
      _ => <String>[],
    };
    return [
      if (current.isNotEmpty && !options.contains(current)) current,
      ...options,
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
