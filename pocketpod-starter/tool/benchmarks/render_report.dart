import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

void main() {
  final resultDir = Directory('tool/benchmarks/results');
  final micro = _readJson(p.join(resultDir.path, 'phase2-micro-baseline.json'));
  final production = _readJson(
    p.join(resultDir.path, 'production-target-serverpod.json'),
  );

  final tabs = <ReportTab>[
    _overviewTab(micro, production),
    ..._scenarioTabs(
      titlePrefix: 'Micro',
      resultSet: micro,
      scenarioOrder: const [
        'smoke',
        'read-only',
        'write-only',
        'mixed-80-20',
        'burst-writes',
      ],
    ),
    ..._scenarioTabs(
      titlePrefix: 'Production',
      resultSet: production,
      scenarioOrder: const [
        'smoke',
        'prod-catalog-browse',
        'prod-detail-heavy',
        'prod-content-commerce',
        'prod-admin-write',
        'prod-peak-checkout',
      ],
    ),
  ];

  final html = _renderHtml(tabs);
  final output = File(p.join(resultDir.path, 'benchmark-report.html'));
  output.writeAsStringSync(html);
  stdout.writeln('Wrote ${output.path}');
}

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

ReportTab _overviewTab(
  Map<String, dynamic> micro,
  Map<String, dynamic> production,
) {
  final microResults = _rows(micro);
  final productionResults = _rows(production);
  final tuned = microResults.where(
    (row) => row.target == 'serverpod-sqlite-tuned',
  );
  final untuned = microResults.where(
    (row) => row.target == 'serverpod-sqlite-untuned',
  );
  final prodC100 = productionResults
      .where((row) => row.concurrency == 100 && row.scenario != 'smoke')
      .toList();

  final notes = [
    'The first Phase 2 micro benchmark is preserved and visualized here beside the production target run.',
    'The production target run used 10,000 seeded rows, 1,000 requests per scenario, and 50/75/100 concurrent request slots.',
    'The selected production starting point is tuned Serverpod SQLite with 5 readers, WAL, synchronous=NORMAL, and a 5s busy timeout.',
    'Every saved result completed with zero benchmark errors.',
  ];

  final tunedMixed = _find(tuned, 'mixed-80-20', 10);
  final untunedMixed = _find(untuned, 'mixed-80-20', 10);
  final tunedBurst = _find(tuned, 'burst-writes', 50);
  final untunedBurst = _find(untuned, 'burst-writes', 50);

  final highlights = <Highlight>[
    Highlight(
      label: 'Micro mixed C10 p95',
      value:
          '${tunedMixed.p95Ms.toStringAsFixed(2)} ms tuned vs ${untunedMixed.p95Ms.toStringAsFixed(2)} ms untuned',
    ),
    Highlight(
      label: 'Micro burst C50 p95',
      value:
          '${tunedBurst.p95Ms.toStringAsFixed(2)} ms tuned vs ${untunedBurst.p95Ms.toStringAsFixed(2)} ms untuned',
    ),
    Highlight(
      label: 'Production worst C100 p95',
      value:
          '${prodC100.map((row) => row.p95Ms).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} ms',
    ),
    Highlight(
      label: 'Production C100 errors',
      value: '${prodC100.fold<int>(0, (sum, row) => sum + row.errors)}',
    ),
  ];

  return ReportTab(
    id: 'overview',
    title: 'Overview',
    notes: notes,
    highlights: highlights,
    rows: [
      ...microResults.where(
        (row) =>
            row.target.startsWith('serverpod') &&
            ((row.scenario == 'mixed-80-20' && row.concurrency == 10) ||
                (row.scenario == 'burst-writes' && row.concurrency == 50)),
      ),
      ...prodC100,
    ],
    chartMode: ChartMode.overview,
  );
}

List<ReportTab> _scenarioTabs({
  required String titlePrefix,
  required Map<String, dynamic> resultSet,
  required List<String> scenarioOrder,
}) {
  final rows = _rows(resultSet);
  return [
    for (final scenario in scenarioOrder)
      if (rows.any((row) => row.scenario == scenario))
        _scenarioTab(titlePrefix, resultSet, scenario),
  ];
}

ReportTab _scenarioTab(
  String titlePrefix,
  Map<String, dynamic> resultSet,
  String scenario,
) {
  final rows =
      _rows(resultSet).where((row) => row.scenario == scenario).toList()
        ..sort((a, b) {
          final scenarioCompare = a.scenario.compareTo(b.scenario);
          if (scenarioCompare != 0) return scenarioCompare;
          final concurrencyCompare = a.concurrency.compareTo(b.concurrency);
          if (concurrencyCompare != 0) return concurrencyCompare;
          return a.target.compareTo(b.target);
        });

  final zeroErrors = rows.fold<int>(0, (sum, row) => sum + row.errors) == 0;
  final fastest = rows.reduce((a, b) => a.throughput > b.throughput ? a : b);
  final lowestP95 = rows.reduce((a, b) => a.p95Ms < b.p95Ms ? a : b);
  final highestP95 = rows.reduce((a, b) => a.p95Ms > b.p95Ms ? a : b);

  final notes = [
    _scenarioMeaning(scenario),
    'Errors: ${zeroErrors ? 'none' : rows.fold<int>(0, (sum, row) => sum + row.errors)}.',
    'Lowest p95: ${lowestP95.target} at C${lowestP95.concurrency}, ${lowestP95.p95Ms.toStringAsFixed(2)} ms.',
    'Highest throughput: ${fastest.target} at C${fastest.concurrency}, ${fastest.throughput.toStringAsFixed(1)} req/s.',
    if (scenario.startsWith('prod-'))
      'Production target lens: watch C100 first, because that is the top end of the stated user concurrency goal.',
  ];

  return ReportTab(
    id: '${titlePrefix.toLowerCase()}-${scenario.replaceAll(RegExp('[^a-zA-Z0-9]+'), '-')}',
    title: '$titlePrefix: ${_prettyScenario(scenario)}',
    notes: notes,
    highlights: [
      Highlight(label: 'Rows', value: '${rows.length}'),
      Highlight(
        label: 'Lowest p95',
        value: '${lowestP95.p95Ms.toStringAsFixed(2)} ms',
      ),
      Highlight(
        label: 'Highest p95',
        value: '${highestP95.p95Ms.toStringAsFixed(2)} ms',
      ),
      Highlight(
        label: 'Best throughput',
        value: '${fastest.throughput.toStringAsFixed(1)} req/s',
      ),
    ],
    rows: rows,
    chartMode: ChartMode.scenario,
    meta: {
      'profile': resultSet['profile'] ?? 'micro',
      'seed': resultSet['seed'],
      'requests': resultSet['requests'],
      if (resultSet.containsKey('sqliteReaders'))
        'sqliteReaders': resultSet['sqliteReaders'],
    },
  );
}

BenchRow _find(Iterable<BenchRow> rows, String scenario, int concurrency) {
  return rows.firstWhere(
    (row) => row.scenario == scenario && row.concurrency == concurrency,
  );
}

List<BenchRow> _rows(Map<String, dynamic> resultSet) {
  return [
    for (final row in resultSet['results'] as List<dynamic>)
      BenchRow.fromJson(row as Map<String, dynamic>),
  ];
}

String _scenarioMeaning(String scenario) {
  return switch (scenario) {
    'smoke' =>
      'Startup and basic mixed operation check. Use this as a sanity check, not a capacity claim.',
    'read-only' =>
      'Microbenchmark read traffic using a mix of single-record and small-list reads.',
    'write-only' =>
      'Microbenchmark write traffic. This exposes SQLite write serialization and busy-timeout behavior.',
    'mixed-80-20' => 'Microbenchmark 80% read / 20% write mix.',
    'burst-writes' =>
      'Microbenchmark simultaneous write pressure at higher concurrency.',
    'prod-catalog-browse' =>
      'Production-style catalog browsing: mostly list/page reads with some detail reads.',
    'prod-detail-heavy' =>
      'Production-style detail traffic: product/post detail pages dominate.',
    'prod-content-commerce' =>
      'Production-style content and commerce traffic: 95% reads with occasional writes.',
    'prod-admin-write' =>
      'Production-style admin/content/product update pressure: 80% reads, 20% writes.',
    'prod-peak-checkout' =>
      'Production-style peak checkout/order pressure: 70% reads, 30% writes.',
    _ => 'Benchmark scenario.',
  };
}

String _prettyScenario(String scenario) {
  return scenario
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _renderHtml(List<ReportTab> tabs) {
  final data = jsonEncode([for (final tab in tabs) tab.toJson()]);
  return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>PocketPod Benchmark Report</title>
  <style>
    :root {
      color-scheme: light;
      --bg: #f7f8fa;
      --panel: #ffffff;
      --ink: #18202a;
      --muted: #596575;
      --line: #d9dee7;
      --accent: #156f8f;
      --accent-2: #7b5d1e;
      --ok: #0e7a4f;
      --warn: #9a5b00;
      --radius: 8px;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.45;
    }
    header {
      padding: 28px 32px 18px;
      border-bottom: 1px solid var(--line);
      background: #ffffff;
    }
    h1 { margin: 0 0 6px; font-size: 28px; letter-spacing: 0; }
    .subtitle { color: var(--muted); max-width: 980px; }
    main { padding: 20px 32px 40px; }
    .tabs {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 18px;
    }
    .tab-button {
      border: 1px solid var(--line);
      background: #fff;
      border-radius: var(--radius);
      padding: 8px 11px;
      color: var(--ink);
      cursor: pointer;
      font-size: 13px;
    }
    .tab-button.active {
      border-color: var(--accent);
      background: #e9f5f9;
      color: #08465c;
      font-weight: 650;
    }
    .tab-panel { display: none; }
    .tab-panel.active { display: block; }
    .summary {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 18px;
      margin-bottom: 16px;
    }
    h2 { margin: 0 0 10px; font-size: 22px; }
    .notes { margin: 0; padding-left: 20px; color: var(--muted); }
    .highlights {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 10px;
      margin-top: 16px;
    }
    .metric {
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 12px;
      background: #fbfcfd;
    }
    .metric-label { color: var(--muted); font-size: 12px; }
    .metric-value { font-weight: 750; margin-top: 4px; font-size: 18px; }
    .chart-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
      gap: 16px;
      margin-bottom: 16px;
    }
    .chart-card, .table-card {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 14px;
      overflow: auto;
    }
    .chart-title {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 8px;
    }
    svg { width: 100%; height: 280px; display: block; }
    .axis { stroke: #aeb7c4; stroke-width: 1; }
    .grid { stroke: #edf0f4; stroke-width: 1; }
    .label { fill: var(--muted); font-size: 11px; }
    .legend { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 8px; font-size: 12px; color: var(--muted); }
    .swatch { display: inline-block; width: 10px; height: 10px; border-radius: 2px; margin-right: 5px; vertical-align: -1px; }
    .point-label {
      opacity: 0;
      pointer-events: none;
      transition: opacity 120ms ease;
    }
    .point:hover .point-label,
    .point:focus .point-label {
      opacity: 1;
    }
    .point-label-bg {
      fill: #ffffff;
      stroke: #aeb7c4;
      stroke-width: 1;
    }
    .point-label-text {
      fill: #111827;
      font-size: 12px;
      font-weight: 750;
    }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th, td { padding: 8px 9px; border-bottom: 1px solid var(--line); text-align: right; white-space: nowrap; }
    th:first-child, td:first-child, th:nth-child(2), td:nth-child(2) { text-align: left; }
    th { color: var(--muted); font-weight: 700; background: #fbfcfd; position: sticky; top: 0; }
    .good { color: var(--ok); font-weight: 700; }
    .warn { color: var(--warn); font-weight: 700; }
    @media (max-width: 700px) {
      header, main { padding-left: 16px; padding-right: 16px; }
      .chart-grid { grid-template-columns: 1fr; }
      .tab-button { font-size: 12px; }
    }
  </style>
</head>
<body>
  <header>
    <h1>PocketPod Benchmark Report</h1>
    <div class="subtitle">Micro baseline plus production-oriented Serverpod SQLite target. Charts show p95 latency and throughput; tables include every saved result row for each tab.</div>
  </header>
  <main>
    <nav id="tabs" class="tabs"></nav>
    <section id="panels"></section>
  </main>
  <script>
    const tabs = $data;
    const colors = ['#0072B2', '#D55E00', '#009E73', '#CC79A7', '#E69F00', '#111827', '#56B4E9', '#7F3C8D'];

    function fmt(value, digits = 1) {
      return Number(value).toLocaleString(undefined, { maximumFractionDigits: digits, minimumFractionDigits: digits });
    }

    function init() {
      const tabNav = document.getElementById('tabs');
      const panels = document.getElementById('panels');
      tabs.forEach((tab, index) => {
        const button = document.createElement('button');
        button.className = 'tab-button' + (index === 0 ? ' active' : '');
        button.textContent = tab.title;
        button.addEventListener('click', () => activate(tab.id));
        tabNav.appendChild(button);

        const panel = document.createElement('article');
        panel.className = 'tab-panel' + (index === 0 ? ' active' : '');
        panel.id = tab.id;
        panel.innerHTML = renderPanel(tab);
        panels.appendChild(panel);
        renderCharts(panel, tab);
      });
    }

    function activate(id) {
      document.querySelectorAll('.tab-button').forEach((button, index) => {
        button.classList.toggle('active', tabs[index].id === id);
      });
      document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.toggle('active', panel.id === id);
      });
    }

    function renderPanel(tab) {
      const notes = tab.notes.map(note => '<li>' + escapeHtml(note) + '</li>').join('');
      const metrics = tab.highlights.map(metric => `
        <div class="metric">
          <div class="metric-label">\${escapeHtml(metric.label)}</div>
          <div class="metric-value">\${escapeHtml(metric.value)}</div>
        </div>`).join('');
      return `
        <div class="summary">
          <h2>\${escapeHtml(tab.title)}</h2>
          <ul class="notes">\${notes}</ul>
          <div class="highlights">\${metrics}</div>
        </div>
        <div class="chart-grid">
          <div class="chart-card">
            <div class="chart-title">p95 Latency (ms)</div>
            <div class="chart" data-kind="p95"></div>
          </div>
          <div class="chart-card">
            <div class="chart-title">Throughput (requests/sec)</div>
            <div class="chart" data-kind="throughput"></div>
          </div>
        </div>
        <div class="table-card">
          \${renderTable(tab.rows)}
        </div>`;
    }

    function renderTable(rows) {
      return `
        <table>
          <thead>
            <tr>
              <th>Target</th><th>Scenario</th><th>C</th><th>Requests</th><th>Errors</th>
              <th>Throughput</th><th>p50</th><th>p95</th><th>p99</th><th>Max</th><th>DB bytes</th>
            </tr>
          </thead>
          <tbody>
            \${rows.map(row => `
              <tr>
                <td>\${escapeHtml(row.target)}</td>
                <td>\${escapeHtml(row.scenario)}</td>
                <td>\${row.concurrency}</td>
                <td>\${row.requests}</td>
                <td class="\${row.errors === 0 ? 'good' : 'warn'}">\${row.errors}</td>
                <td>\${fmt(row.throughput, 1)}</td>
                <td>\${fmt(row.p50Ms, 2)}</td>
                <td>\${fmt(row.p95Ms, 2)}</td>
                <td>\${fmt(row.p99Ms, 2)}</td>
                <td>\${fmt(row.maxMs, 2)}</td>
                <td>\${Number(row.databaseBytes).toLocaleString()}</td>
              </tr>`).join('')}
          </tbody>
        </table>`;
    }

    function renderCharts(panel, tab) {
      panel.querySelectorAll('.chart').forEach(node => {
        const kind = node.dataset.kind;
        const valueField = kind === 'p95' ? 'p95Ms' : 'throughput';
        const suffix = kind === 'p95' ? ' ms' : ' req/s';
        node.innerHTML = lineChart(tab.rows, valueField, suffix);
      });
    }

    function lineChart(rows, valueField, suffix) {
      const width = 720, height = 280;
      const margin = { top: 16, right: 22, bottom: 42, left: 58 };
      const innerW = width - margin.left - margin.right;
      const innerH = height - margin.top - margin.bottom;
      const xs = [...new Set(rows.map(row => row.concurrency))].sort((a, b) => a - b);
      const groups = [...new Set(rows.map(row => row.target))];
      const values = rows.map(row => row[valueField]);
      const maxValue = Math.max(...values, 1) * 1.12;
      const xScale = x => margin.left + (xs.length === 1 ? innerW / 2 : xs.indexOf(x) * (innerW / (xs.length - 1)));
      const yScale = y => margin.top + innerH - (y / maxValue) * innerH;
      const yTicks = [0, maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
      const xAxis = xs.map(x => `<text class="label" x="\${xScale(x)}" y="\${height - 14}" text-anchor="middle">C\${x}</text>`).join('');
      const yAxis = yTicks.map(y => `
        <line class="grid" x1="\${margin.left}" x2="\${width - margin.right}" y1="\${yScale(y)}" y2="\${yScale(y)}"></line>
        <text class="label" x="\${margin.left - 8}" y="\${yScale(y) + 4}" text-anchor="end">\${fmt(y, valueField === 'p95Ms' ? 0 : 0)}</text>`).join('');

      const lines = groups.map((group, groupIndex) => {
        const groupRows = rows.filter(row => row.target === group).sort((a, b) => a.concurrency - b.concurrency);
        const points = groupRows.map(row => [xScale(row.concurrency), yScale(row[valueField]), row]);
        const path = points.map((point, index) => `\${index === 0 ? 'M' : 'L'} \${point[0]} \${point[1]}`).join(' ');
        const color = colors[groupIndex % colors.length];
        const circles = points.map(point => {
          const label = `\${fmt(point[2][valueField], 2)}\${suffix}`;
          const labelWidth = Math.max(54, label.length * 7.2 + 12);
          const labelX = Math.min(Math.max(point[0] - labelWidth / 2, margin.left), width - margin.right - labelWidth);
          const labelY = Math.max(point[1] - 34, margin.top + 4);
          return `
            <g class="point" tabindex="0">
              <circle cx="\${point[0]}" cy="\${point[1]}" r="5" fill="\${color}" stroke="#ffffff" stroke-width="1.5">
                <title>\${group} C\${point[2].concurrency}: \${label}</title>
              </circle>
              <g class="point-label">
                <rect class="point-label-bg" x="\${labelX}" y="\${labelY}" width="\${labelWidth}" height="22" rx="4"></rect>
                <text class="point-label-text" x="\${labelX + labelWidth / 2}" y="\${labelY + 15}" text-anchor="middle">\${label}</text>
              </g>
            </g>`;
        }).join('');
        return `<path d="\${path}" fill="none" stroke="\${color}" stroke-width="3"></path>\${circles}`;
      }).join('');

      const legend = groups.map((group, index) => `<span><span class="swatch" style="background:\${colors[index % colors.length]}"></span>\${escapeHtml(group)}</span>`).join('');
      return `
        <svg viewBox="0 0 \${width} \${height}" role="img">
          \${yAxis}
          <line class="axis" x1="\${margin.left}" x2="\${width - margin.right}" y1="\${height - margin.bottom}" y2="\${height - margin.bottom}"></line>
          <line class="axis" x1="\${margin.left}" x2="\${margin.left}" y1="\${margin.top}" y2="\${height - margin.bottom}"></line>
          \${xAxis}
          \${lines}
        </svg>
        <div class="legend">\${legend}</div>`;
    }

    function escapeHtml(value) {
      return String(value)
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
    }

    init();
  </script>
</body>
</html>
''';
}

class ReportTab {
  final String id;
  final String title;
  final List<String> notes;
  final List<Highlight> highlights;
  final List<BenchRow> rows;
  final ChartMode chartMode;
  final Map<String, Object?> meta;

  ReportTab({
    required this.id,
    required this.title,
    required this.notes,
    required this.highlights,
    required this.rows,
    required this.chartMode,
    this.meta = const {},
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'highlights': [for (final highlight in highlights) highlight.toJson()],
    'rows': [for (final row in rows) row.toJson()],
    'chartMode': chartMode.name,
    'meta': meta,
  };
}

class Highlight {
  final String label;
  final String value;

  Highlight({required this.label, required this.value});

  Map<String, Object?> toJson() => {'label': label, 'value': value};
}

enum ChartMode { overview, scenario }

class BenchRow {
  final String target;
  final String scenario;
  final int concurrency;
  final int requests;
  final int errors;
  final int databaseBytes;
  final double throughput;
  final double p50Ms;
  final double p95Ms;
  final double p99Ms;
  final double maxMs;

  BenchRow({
    required this.target,
    required this.scenario,
    required this.concurrency,
    required this.requests,
    required this.errors,
    required this.databaseBytes,
    required this.throughput,
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.maxMs,
  });

  factory BenchRow.fromJson(Map<String, dynamic> json) {
    return BenchRow(
      target: json['target'] as String,
      scenario: json['scenario'] as String,
      concurrency: json['concurrency'] as int,
      requests: json['requests'] as int,
      errors: json['errors'] as int,
      databaseBytes: json['databaseBytes'] as int,
      throughput: (json['throughput'] as num).toDouble(),
      p50Ms: (json['p50Ms'] as num).toDouble(),
      p95Ms: (json['p95Ms'] as num).toDouble(),
      p99Ms: (json['p99Ms'] as num).toDouble(),
      maxMs: (json['maxMs'] as num).toDouble(),
    );
  }

  Map<String, Object?> toJson() => {
    'target': target,
    'scenario': scenario,
    'concurrency': concurrency,
    'requests': requests,
    'errors': errors,
    'databaseBytes': databaseBytes,
    'throughput': throughput,
    'p50Ms': p50Ms,
    'p95Ms': p95Ms,
    'p99Ms': p99Ms,
    'maxMs': maxMs,
  };
}
