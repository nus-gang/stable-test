#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f go.mod ]; then
  echo "chain/go.mod not found. Generate the Cosmos SDK scaffold in chain/ first."
  echo "Expected baseline: Cosmos SDK v0.53.7, Go 1.23.2, CometBFT v0.38.21."
  exit 2
fi

if command -v make >/dev/null 2>&1 && grep -q '^build:' Makefile 2>/dev/null; then
  make build
else
  go build ./...
fi
