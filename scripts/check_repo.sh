#!/usr/bin/env bash
set -euo pipefail
printf 'Repository skeleton check\n'
for d in chain indexer api wallet-web scan-web admin-web infra docs; do
  test -d "$d" || { echo "Missing $d"; exit 1; }
done
test -f README.md
test -f docs/00_Documentation_Index.md
test -f docs/backlog/Initial_Backlog_v1.md
echo 'OK'
