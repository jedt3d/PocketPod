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

    return AdminShell(session: session, onLogout: _logout);
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

class AdminShell extends StatelessWidget {
  const AdminShell({required this.session, required this.onLogout, super.key});

  final AdminSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminSidebar(),
            Expanded(
              child: AdminWorkspace(session: session, onLogout: onLogout),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

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
          const _CollectionNavItem(
            label: 'Admin Input Examples',
            count: 2,
            selected: true,
          ),
          const _CollectionNavItem(label: 'Products', count: 3),
          const _CollectionNavItem(label: 'Posts', count: 2),
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
    required this.onLogout,
    super.key,
  });

  final AdminSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
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
          _MetricStrip(session: session),
          const SizedBox(height: 18),
          const Expanded(child: _CollectionPanel()),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.session});

  final AdminSession session;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _MetricCard(label: 'Auth', value: 'Serverpod'),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: _MetricCard(label: 'Required Scope', value: 'admin'),
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
  const _CollectionPanel();

  @override
  Widget build(BuildContext context) {
    final placeholderClient = Client('http://localhost:8080/');

    return Card(
      clipBehavior: Clip.antiAlias,
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
                  'Admin Input Examples',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'API base ready for ${placeholderClient.host}.',
                  key: const Key('client_base_line'),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FieldChip('text'),
                _FieldChip('textarea'),
                _FieldChip('checkbox'),
                _FieldChip('datetime'),
                _FieldChip('dropdown'),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(
              child: Text(
                'Collection data loads in Cycle 3.',
                key: Key('cycle_1_placeholder'),
              ),
            ),
          ),
        ],
      ),
    );
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
  });

  final String label;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD7F4EF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
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
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: const BorderSide(color: Color(0xFFD9DEE7)),
      backgroundColor: const Color(0xFFF8FAFC),
      visualDensity: VisualDensity.compact,
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
