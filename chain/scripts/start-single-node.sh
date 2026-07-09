#!/usr/bin/env bash
set -euo pipefail

CHAIN_BINARY="${CHAIN_BINARY:-stablecoind}"
CHAIN_ID="${CHAIN_ID:-stablecoin-private-1}"
CHAIN_HOME="${CHAIN_HOME:-/workspace/.chain-data/local}"
MONIKER="${MONIKER:-local-validator}"

if ! command -v "$CHAIN_BINARY" >/dev/null 2>&1; then
  echo "Chain binary '$CHAIN_BINARY' not found in PATH."
  echo "Build/install the scaffolded chain binary first."
  exit 2
fi

mkdir -p "$CHAIN_HOME"

if [ ! -f "$CHAIN_HOME/config/genesis.json" ]; then
  "$CHAIN_BINARY" init "$MONIKER" --chain-id "$CHAIN_ID" --home "$CHAIN_HOME"
  echo "Initialized single-node chain home at $CHAIN_HOME."
  echo "TODO after scaffold: add genesis accounts, gentx, collect-gentxs, and USDX genesis policy."
  exit 0
fi

exec "$CHAIN_BINARY" start --home "$CHAIN_HOME"
