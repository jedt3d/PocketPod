import 'package:flutter/material.dart';
import 'package:pocketpod_client/pocketpod_client.dart';

void main() {
  runApp(const PocketPodAdminApp());
}

class PocketPodAdminApp extends StatelessWidget {
  const PocketPodAdminApp({super.key});

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
      home: const AdminShell(),
    );
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminSidebar(),
            Expanded(child: AdminWorkspace()),
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
  const AdminWorkspace({super.key});

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
                    const Text(
                      'Cycle 1 baseline shell. Serverpod client wired.',
                      key: Key('admin_status_line'),
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: null,
                child: const Text('Sign in pending'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _MetricStrip(),
          const SizedBox(height: 18),
          const Expanded(child: _CollectionPanel()),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MetricCard(label: 'Auth', value: 'Serverpod'),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _MetricCard(label: 'Required Scope', value: 'admin'),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _MetricCard(label: 'Client', value: 'wired'),
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
