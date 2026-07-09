#!/usr/bin/env bash
set -euo pipefail

CHAIN_BINARY="${CHAIN_BINARY:-stablecoind}"
CHAIN_ID="${CHAIN_ID:-stablecoin-private-1}"
CHAIN_HOME="${CHAIN_HOME:-/workspace/.chain-data/devnet/${VALIDATOR_NAME:-validator}}"
VALIDATOR_NAME="${VALIDATOR_NAME:-validator}"

if ! command -v "$CHAIN_BINARY" >/dev/null 2>&1; then
  echo "Chain binary '$CHAIN_BINARY' not found in PATH."
  echo "This devnet compose is scaffold-ready and will run after chain binary generation."
  sleep infinity
fi

mkdir -p "$CHAIN_HOME"

if [ ! -f "$CHAIN_HOME/config/genesis.json" ]; then
  "$CHAIN_BINARY" init "$VALIDATOR_NAME" --chain-id "$CHAIN_ID" --home "$CHAIN_HOME"
  echo "Initialized $VALIDATOR_NAME at $CHAIN_HOME."
  echo "TODO after scaffold: shared genesis, persistent peers, gentx collection."
  sleep infinity
fi

exec "$CHAIN_BINARY" start --home "$CHAIN_HOME"
