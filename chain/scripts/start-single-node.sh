#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHAIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$CHAIN_DIR/.." && pwd)"

CHAIN_BINARY="${CHAIN_BINARY:-stablecoind}"
CHAIN_ID="${CHAIN_ID:-stablecoin-private-1}"
CHAIN_HOME="${CHAIN_HOME:-$REPO_ROOT/.chain-data/local}"
MONIKER="${MONIKER:-local-validator}"
KEY_NAME="${KEY_NAME:-validator}"
KEYRING_BACKEND="${KEYRING_BACKEND:-test}"
DENOM="${DENOM:-uusdx}"
GENESIS_ACCOUNT_AMOUNT="${GENESIS_ACCOUNT_AMOUNT:-100000000000${DENOM}}"
GENTX_STAKE_AMOUNT="${GENTX_STAKE_AMOUNT:-100000000${DENOM}}"
RESET_HOME="${RESET_HOME:-0}"
MIN_GAS_PRICES="${MIN_GAS_PRICES:-0${DENOM}}"

export PATH="$(go env GOPATH 2>/dev/null || echo /go)/bin:$PATH"

install_binary_if_needed() {
  if command -v "$CHAIN_BINARY" >/dev/null 2>&1; then
    return 0
  fi

  if [ ! -f "$CHAIN_DIR/go.mod" ]; then
    cat >&2 <<ERR
Chain binary '$CHAIN_BINARY' not found in PATH and $CHAIN_DIR/go.mod does not exist.
Generate the Cosmos SDK scaffold first, then build/install the chain binary.
ERR
    return 2
  fi

  if [ ! -d "$CHAIN_DIR/cmd/$CHAIN_BINARY" ]; then
    cat >&2 <<ERR
Chain binary '$CHAIN_BINARY' not found in PATH and $CHAIN_DIR/cmd/$CHAIN_BINARY does not exist.
Available command packages:
$(find "$CHAIN_DIR/cmd" -maxdepth 2 -type f -name main.go -print 2>/dev/null || true)
Set CHAIN_BINARY to the generated command name and retry.
ERR
    return 2
  fi

  echo "Chain binary '$CHAIN_BINARY' not found in PATH. Installing from ./cmd/$CHAIN_BINARY ..."
  (cd "$CHAIN_DIR" && go mod tidy && go install "./cmd/$CHAIN_BINARY")
}

run_genesis_cmd() {
  # Cosmos SDK v0.50+ uses '<binary> genesis ...'. Some older apps used root-level commands.
  if "$CHAIN_BINARY" genesis --help >/dev/null 2>&1; then
    "$CHAIN_BINARY" genesis "$@"
  else
    "$CHAIN_BINARY" "$@"
  fi
}

configure_app_toml() {
  local app_toml="$CHAIN_HOME/config/app.toml"
  if [ ! -f "$app_toml" ]; then
    return 0
  fi

  echo "Configuring minimum-gas-prices=$MIN_GAS_PRICES in $app_toml"
  if grep -q '^minimum-gas-prices *= *' "$app_toml"; then
    sed -i.bak "s/^minimum-gas-prices *= *.*/minimum-gas-prices = \"$MIN_GAS_PRICES\"/" "$app_toml"
  else
    printf '\nminimum-gas-prices = "%s"\n' "$MIN_GAS_PRICES" >> "$app_toml"
  fi
  rm -f "$app_toml.bak"
}

install_binary_if_needed

echo "Using chain binary: $(command -v "$CHAIN_BINARY")"
"$CHAIN_BINARY" version || true

if [ "$RESET_HOME" = "1" ]; then
  echo "RESET_HOME=1 set; removing $CHAIN_HOME"
  rm -rf "$CHAIN_HOME"
fi

mkdir -p "$CHAIN_HOME"

if [ ! -f "$CHAIN_HOME/config/genesis.json" ]; then
  echo "Initializing single-node chain home at $CHAIN_HOME"
  "$CHAIN_BINARY" init "$MONIKER" --chain-id "$CHAIN_ID" --home "$CHAIN_HOME"

  echo "Creating or reusing validator key: $KEY_NAME"
  if ! "$CHAIN_BINARY" keys show "$KEY_NAME" --home "$CHAIN_HOME" --keyring-backend "$KEYRING_BACKEND" >/dev/null 2>&1; then
    "$CHAIN_BINARY" keys add "$KEY_NAME" --home "$CHAIN_HOME" --keyring-backend "$KEYRING_BACKEND"
  fi

  echo "Adding genesis account: $GENESIS_ACCOUNT_AMOUNT"
  run_genesis_cmd add-genesis-account "$KEY_NAME" "$GENESIS_ACCOUNT_AMOUNT" \
    --home "$CHAIN_HOME" \
    --keyring-backend "$KEYRING_BACKEND"

  echo "Creating gentx: $GENTX_STAKE_AMOUNT"
  run_genesis_cmd gentx "$KEY_NAME" "$GENTX_STAKE_AMOUNT" \
    --chain-id "$CHAIN_ID" \
    --home "$CHAIN_HOME" \
    --keyring-backend "$KEYRING_BACKEND"

  echo "Collecting gentxs"
  run_genesis_cmd collect-gentxs --home "$CHAIN_HOME"

  echo "Validating genesis"
  run_genesis_cmd validate-genesis --home "$CHAIN_HOME"
else
  echo "Existing genesis found at $CHAIN_HOME/config/genesis.json"
fi

configure_app_toml

cat <<INFO

Starting single-node chain
  CHAIN_ID=$CHAIN_ID
  CHAIN_HOME=$CHAIN_HOME
  MONIKER=$MONIKER
  DENOM=$DENOM
  MIN_GAS_PRICES=$MIN_GAS_PRICES

Stop with Ctrl+C.
INFO

exec "$CHAIN_BINARY" start --home "$CHAIN_HOME"
