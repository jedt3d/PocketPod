#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Refresh the in-repository PocketPod starter and Serverpod source copy.

Default layout, when run from the PocketPod repository root:
  ./pocketpod-starter      canonical starter app/template
  ./serverpod-pocketpod    local Serverpod source copy with SQLite tuning

Usage:
  tool/automation/create_pocketpod_repos.sh [options]

Options:
  --starter-source PATH      Source starter directory. Default: ./pocketpod-starter.
  --starter-target PATH        Output path for pocketpod-starter.
  --serverpod-source PATH      Source Serverpod checkout. Default: ../ServerPod.
  --serverpod-target PATH      Output path for serverpod-pocketpod.
  --force                      Replace existing generated targets before copying.
  -h, --help                   Show this help.

Examples:
  # Patch the canonical starter in place and keep existing Serverpod copy.
  tool/automation/create_pocketpod_repos.sh

  # Refresh the Serverpod source copy from ../ServerPod.
  tool/automation/create_pocketpod_repos.sh --force

  # Copy the canonical starter to another local directory.
  tool/automation/create_pocketpod_repos.sh \
    --starter-target /tmp/pocketpod-starter \
    --serverpod-target /tmp/serverpod-pocketpod \
    --force
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"
workspace_parent="$(cd "$project_root/.." && pwd)"

starter_source="$project_root/pocketpod-starter"
starter_target="$project_root/pocketpod-starter"
serverpod_source="$workspace_parent/ServerPod"
serverpod_target="$project_root/serverpod-pocketpod"
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --starter-source)
      starter_source="$2"
      shift 2
      ;;
    --starter-target)
      starter_target="$2"
      shift 2
      ;;
    --serverpod-source)
      serverpod_source="$2"
      shift 2
      ;;
    --serverpod-target)
      serverpod_target="$2"
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ ! -d "$serverpod_source/packages/serverpod_database" ]]; then
  echo "Serverpod source does not look valid: $serverpod_source" >&2
  exit 1
fi

if [[ ! -f "$serverpod_source/SERVERPOD_VERSION" ]]; then
  echo "Serverpod source is missing SERVERPOD_VERSION: $serverpod_source" >&2
  exit 1
fi

if [[ ! -f "$starter_source/pubspec.yaml" || ! -d "$starter_source/pocketpod_server" ]]; then
  echo "Starter source does not look valid: $starter_source" >&2
  exit 1
fi

serverpod_version="$(tr -d '[:space:]' < "$serverpod_source/SERVERPOD_VERSION")"
pocketpod_version="0.1.0"
pocketpod_release_tag="v${pocketpod_version}+serverpod.${serverpod_version}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required tool not found: $1" >&2
    exit 1
  fi
}

require_tool rsync
require_tool python3

safe_prepare_target() {
  local target="$1"
  local label="$2"

  if [[ -e "$target" ]]; then
    if [[ "$force" != true ]]; then
      echo "$label already exists: $target" >&2
      echo "Use --force to replace it." >&2
      exit 1
    fi

    case "$(basename "$target")" in
      pocketpod-starter|serverpod-pocketpod) ;;
      *)
        echo "Refusing to remove unexpected target path: $target" >&2
        echo "Use a target basename of pocketpod-starter or serverpod-pocketpod." >&2
        exit 1
        ;;
    esac

    rm -rf "$target"
  fi

  mkdir -p "$target"
}

copy_starter() {
  local source_abs
  local target_abs

  source_abs="$(cd "$starter_source" && pwd)"
  mkdir -p "$(dirname "$starter_target")"
  if [[ -d "$starter_target" ]]; then
    target_abs="$(cd "$starter_target" && pwd)"
  else
    target_abs="$(cd "$(dirname "$starter_target")" && pwd)/$(basename "$starter_target")"
  fi

  if [[ "$source_abs" == "$target_abs" ]]; then
    echo "Starter target is the canonical starter source; patching in place."
  else
    safe_prepare_target "$starter_target" "Starter target"

    rsync -a "$starter_source/" "$starter_target/" \
      --exclude ".git/" \
      --exclude ".DS_Store" \
      --exclude ".dart_tool/" \
      --exclude ".packages" \
      --exclude "pubspec.lock" \
      --exclude "build/" \
      --exclude "tool/automation/" \
      --exclude "*/.dart_tool/" \
      --exclude "*/build/" \
      --exclude "pocketpod_server/.serverpod/" \
      --exclude "pocketpod_server/logs/"
  fi

  patch_starter_pubspec
  patch_starter_docs
  write_starter_readme
}

copy_serverpod() {
  if [[ -e "$serverpod_target" && "$force" != true ]]; then
    if [[ ! -d "$serverpod_target/packages/serverpod_database" ]]; then
      echo "Serverpod target exists but does not look valid: $serverpod_target" >&2
      echo "Use --force to replace it." >&2
      exit 1
    fi
    echo "Serverpod target already exists; leaving source files unchanged."
  else
    safe_prepare_target "$serverpod_target" "Serverpod target"

    rsync -a "$serverpod_source/" "$serverpod_target/" \
      --exclude ".git/" \
      --exclude ".DS_Store" \
      --exclude ".dart_tool/" \
      --exclude ".packages" \
      --exclude "build/" \
      --exclude "*/.dart_tool/" \
      --exclude "*/build/"
  fi

  write_serverpod_readme
}

patch_starter_docs() {
  local summary="$starter_target/system-summary.md"
  if [[ -f "$summary" ]]; then
    python3 - "$summary" <<'PY'
from pathlib import Path
import re
import sys

summary = Path(sys.argv[1])
text = summary.read_text()
text = text.replace("../ServerPod/packages/", "../serverpod-pocketpod/packages/")
text = text.replace("../ServerPod/", "../serverpod-pocketpod/")
text = text.replace(
    "By default, it creates sibling directories:",
    "By default, it creates in-repository directories:",
)
summary.write_text(text)
PY
  fi
}

patch_starter_pubspec() {
  local pubspec="$starter_target/pubspec.yaml"

  python3 - "$pubspec" "$serverpod_target" "$starter_target" <<'PY'
from pathlib import Path
import os
import re
import sys

pubspec = Path(sys.argv[1])
serverpod_target = Path(sys.argv[2]).resolve()
starter_target = Path(sys.argv[3]).resolve()
relative = os.path.relpath(serverpod_target, starter_target)
text = pubspec.read_text()
packages = [
    "serverpod",
    "serverpod_client",
    "serverpod_database",
    "serverpod_flutter",
    "serverpod_lints",
    "serverpod_serialization",
    "serverpod_shared",
    "serverpod_test",
]
override = ["dependency_overrides:"]
for package in packages:
    override.extend([
        f"  {package}:",
        f"    path: {relative}/packages/{package}",
    ])
override_text = "\n".join(override) + "\n"
text = re.sub(r"\ndependency_overrides:\n.*\Z", "\n" + override_text, text, flags=re.S)
pubspec.write_text(text)
PY
}

write_starter_readme() {
  cat > "$starter_target/README.md" <<EOF
# PocketPod Starter

This directory is the reusable PocketPod starter app/template.

It is built on [Serverpod](https://serverpod.dev). PocketPod does not replace Serverpod; it uses Serverpod as the backend framework and adds a SQLite-focused starter configuration, benchmark harness, and local tuning patch.

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight local SQLite deployment feel. PocketBase is not a dependency of this starter; it is used only as inspiration and as one optional benchmark comparison target.

PocketPod version:

\`\`\`text
$pocketpod_version
\`\`\`

Compatible Serverpod baseline:

\`\`\`text
$serverpod_version
\`\`\`

Release tag:

\`\`\`text
$pocketpod_release_tag
\`\`\`

This makes it easy to know both PocketPod's own version and the Serverpod version that the starter and \`serverpod-pocketpod\` source copy are aligned with.

From the repository root, refresh the local path overrides and README files with:

\`\`\`sh
tool/automation/create_pocketpod_repos.sh
\`\`\`

## What Is Inside

\`\`\`text
pocketpod_client/      generated Dart client package
pocketpod_server/      Serverpod backend configured for SQLite
pocketpod_flutter/     Flutter companion app
tool/benchmarks/       benchmark runner and HTML report generator
system-summary.md      architecture, benchmark, and setup notes
\`\`\`

This starter points to the in-repo Serverpod copy:

\`\`\`text
../serverpod-pocketpod/packages/...
\`\`\`

## Main PocketPod Configuration

SQLite database configuration lives in:

\`\`\`text
pocketpod_server/config/development.yaml
pocketpod_server/config/test.yaml
pocketpod_server/config/staging.yaml
pocketpod_server/config/production.yaml
\`\`\`

The important production baseline is:

\`\`\`yaml
database:
  filePath: .serverpod/production/database.sqlite
  maxConnectionCount: 5
\`\`\`

Serverpod's generated password file is intentionally local-only:

\`\`\`text
pocketpod_server/config/passwords.yaml
\`\`\`

Do not commit real project secrets. Generate or copy local passwords when creating a new app from this starter.

The SQLite runtime tuning itself is in:

\`\`\`text
../serverpod-pocketpod/packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
\`\`\`

Look for:

\`\`\`dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
\`\`\`

## Validation Commands

\`\`\`sh
flutter pub get
flutter analyze
dart run tool/benchmarks/run_bench.dart --profile production --targets serverpod-sqlite-tuned
dart run tool/benchmarks/render_report.dart
\`\`\`

Open the generated report:

\`\`\`text
tool/benchmarks/results/benchmark-report.html
\`\`\`
EOF
}

write_serverpod_readme() {
  if [[ -f "$serverpod_target/README.md" ]] &&
    ! grep -q "^# Serverpod PocketPod Fork" "$serverpod_target/README.md"; then
    mv "$serverpod_target/README.md" "$serverpod_target/README.SERVERPOD_UPSTREAM.md"
  fi

  cat > "$serverpod_target/README.md" <<EOF
# Serverpod PocketPod Fork

This directory is the in-repository Serverpod source copy used by PocketPod.

It is not a new backend framework. It is Serverpod with the local PocketPod SQLite tuning patch applied.

## Serverpod Credit

This source tree comes from [Serverpod](https://serverpod.dev). The Serverpod team built the framework, CLI, runtime, protocol generation, and package structure that PocketPod depends on.

PocketPod keeps this copy locally only so the SQLite tuning patch can be inspected, tested, and used by the starter through path dependency overrides.

## PocketBase Inspiration

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight local SQLite deployment feel. PocketBase is not part of this Serverpod source copy; it is referenced only as product inspiration and optional benchmark context.

## Version

PocketPod version:

\`\`\`text
$pocketpod_version
\`\`\`

This copy is based on Serverpod:

\`\`\`text
$serverpod_version
\`\`\`

Release tag:

\`\`\`text
$pocketpod_release_tag
\`\`\`

The PocketPod version is intentionally separate from Serverpod's version so PocketPod can evolve independently. The \`+serverpod.$serverpod_version\` metadata keeps the upstream Serverpod baseline easy to identify.

## Why This Exists

PocketPod needs explicit SQLite runtime settings:

\`\`\`text
journal_mode        : WAL
synchronous         : NORMAL
busy_timeout        : 5000 ms
maxConnectionCount  : 5 in the starter app config
\`\`\`

This in-repo Serverpod copy keeps the patch close to the starter app.

## Main File To Inspect

\`\`\`text
packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
\`\`\`

The important tuning block is:

\`\`\`dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
\`\`\`

The benchmark-only untuned profile is also in this file. It allows comparison against rollback-journal/full-sync/single-reader behavior without maintaining a second Serverpod source tree.

## Related Test

\`\`\`text
packages/serverpod_database/test/sqlite_pool_manager_test.dart
\`\`\`

Run:

\`\`\`sh
cd serverpod-pocketpod/packages/serverpod_database
dart test test/sqlite_pool_manager_test.dart
dart analyze
\`\`\`

## Upstream Serverpod README

The original upstream Serverpod README was preserved as:

\`\`\`text
README.SERVERPOD_UPSTREAM.md
\`\`\`

## How The Starter Uses This Directory

The \`pocketpod-starter/pubspec.yaml\` file points to packages in this directory using path dependency overrides:

\`\`\`yaml
dependency_overrides:
  serverpod:
    path: ../serverpod-pocketpod/packages/serverpod
  serverpod_database:
    path: ../serverpod-pocketpod/packages/serverpod_database
\`\`\`

This keeps everything inside one repository while preserving a clean boundary between:

\`\`\`text
pocketpod-starter      app/template code
serverpod-pocketpod    framework patch code
\`\`\`
EOF
}

echo "PocketPod prototype : $project_root"
echo "Starter source      : $starter_source"
echo "Serverpod source    : $serverpod_source"
echo "Starter target      : $starter_target"
echo "Serverpod target    : $serverpod_target"

copy_serverpod
copy_starter

cat <<EOF

Done.

Updated:
  $serverpod_target
  $starter_target

Recommended next steps:
  cd "$starter_target"
  flutter pub get
  flutter analyze
  dart run tool/benchmarks/run_bench.dart --profile production --targets serverpod-sqlite-tuned
EOF
