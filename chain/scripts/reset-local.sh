#!/usr/bin/env bash
set -euo pipefail

CHAIN_HOME="${CHAIN_HOME:-/workspace/.chain-data/local}"

if [[ "$CHAIN_HOME" != *".chain-data"* ]]; then
  echo "Refusing to delete unexpected CHAIN_HOME: $CHAIN_HOME"
  exit 1
fi

rm -rf "$CHAIN_HOME"
echo "Removed local chain home: $CHAIN_HOME"
