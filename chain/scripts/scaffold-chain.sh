#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAIN_DIR="${CHAIN_DIR:-$REPO_ROOT/chain}"
CHAIN_NAME="${CHAIN_NAME:-stablecoin}"
CHAIN_BINARY="${CHAIN_BINARY:-stablecoind}"
CHAIN_ID="${CHAIN_ID:-stablecoin-private-1}"
ADDRESS_PREFIX="${ADDRESS_PREFIX:-stbc}"
COSMOS_SDK_VERSION="${COSMOS_SDK_VERSION:-v0.53.7}"
BUF_VERSION="${BUF_VERSION:-v1.56.0}"
TMP_PARENT="${TMP_PARENT:-$REPO_ROOT/.tmp}"
SCAFFOLD_DIR="$TMP_PARENT/${CHAIN_NAME}"

usage() {
  cat <<USAGE
Usage: chain/scripts/scaffold-chain.sh [--force]

Creates the initial Cosmos SDK chain scaffold under chain/ using Ignite CLI.

Defaults:
  CHAIN_NAME=$CHAIN_NAME
  CHAIN_BINARY=$CHAIN_BINARY
  CHAIN_ID=$CHAIN_ID
  ADDRESS_PREFIX=$ADDRESS_PREFIX
  COSMOS_SDK_VERSION=$COSMOS_SDK_VERSION
BUF_VERSION=$BUF_VERSION

Environment overrides:
  CHAIN_NAME, CHAIN_BINARY, CHAIN_ID, ADDRESS_PREFIX, COSMOS_SDK_VERSION, BUF_VERSION

Options:
  --force    Allow overwriting an existing scaffold in chain/.
  -h,--help  Show this help.
USAGE
}

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage; exit 1 ;;
  esac
done

if ! command -v ignite >/dev/null 2>&1; then
  cat >&2 <<'ERR'
Ignite CLI is not installed in this environment.
Build and enter the chain development container first:

  docker compose -f infra/docker/docker-compose.chain.yml build chain-dev
  docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev

Then run:

  chain/scripts/scaffold-chain.sh
ERR
  exit 127
fi

if [ -f "$CHAIN_DIR/go.mod" ] && [ "$FORCE" -ne 1 ]; then
  cat >&2 <<ERR
$CHAIN_DIR/go.mod already exists.
Refusing to overwrite an existing chain scaffold.
Use --force only if you intentionally want to regenerate/overwrite scaffold files.
ERR
  exit 2
fi

mkdir -p "$TMP_PARENT"
rm -rf "$SCAFFOLD_DIR"

echo "Ignite version:"
ignite version || true
echo "Creating Cosmos SDK scaffold in temporary directory: $SCAFFOLD_DIR"

cd "$TMP_PARENT"

# Ignite v29.10.x does not expose a stable --sdk-version flag for scaffold chain.
# Generate with the installed Ignite defaults first, then normalize go.mod to the
# MVP baseline below after merging into chain/.
ignite scaffold chain "$CHAIN_NAME" \
  --address-prefix "$ADDRESS_PREFIX" \
  --default-denom "uusdx"

if [ ! -d "$SCAFFOLD_DIR" ]; then
  echo "Expected scaffold directory not found: $SCAFFOLD_DIR" >&2
  exit 1
fi

echo "Merging scaffold into $CHAIN_DIR"
mkdir -p "$CHAIN_DIR"
rsync -a \
  --exclude '.git/' \
  --exclude 'README.md' \
  "$SCAFFOLD_DIR/" "$CHAIN_DIR/"

# Preserve existing project scripts/configs and normalize module metadata where possible.
cd "$CHAIN_DIR"

if [ -f go.mod ]; then
  echo "Ensuring Cosmos SDK baseline in go.mod: $COSMOS_SDK_VERSION"
  if grep -q 'cosmossdk.io' go.mod || grep -q 'github.com/cosmos/cosmos-sdk' go.mod; then
    go get "github.com/cosmos/cosmos-sdk@${COSMOS_SDK_VERSION}" || true
    go get "github.com/bufbuild/buf@${BUF_VERSION}" || true
    go mod edit -go=1.25.12 || true
    go mod edit -toolchain=none 2>/dev/null || true
    GOTOOLCHAIN=auto go mod tidy || true
  fi
fi

cat > configs/scaffold.env <<ENVEOF
CHAIN_NAME=$CHAIN_NAME
CHAIN_BINARY=$CHAIN_BINARY
CHAIN_ID=$CHAIN_ID
ADDRESS_PREFIX=$ADDRESS_PREFIX
DEFAULT_DENOM=uusdx
COSMOS_SDK_VERSION=$COSMOS_SDK_VERSION
BUF_VERSION=$BUF_VERSION
ENVEOF

cat <<DONE

Scaffold merge complete.

Next commands inside the chain-dev container:

  cd chain
  go mod tidy
  ../chain/scripts/build.sh

Then initialize a local node:

  CHAIN_BINARY=$CHAIN_BINARY CHAIN_ID=$CHAIN_ID CHAIN_HOME=/workspace/.chain-data/local chain/scripts/start-single-node.sh

Notes:
- Review generated files before committing.
- If Ignite generated a different binary name, update CHAIN_BINARY or rename command package accordingly.
DONE
