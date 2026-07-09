# Mac Docker Development Setup v1

## 1. 목적

본 문서는 MacBook에서 Docker 기반으로 Stable Test private Cosmos stablecoin chain 개발환경을 구성하는 방법을 정의한다.

대상 환경:

- macOS on Apple Silicon or Intel
- Docker Desktop
- Git
- Optional: VS Code / Cursor

---

## 2. 확정 기술 스택

| Component | Version |
|---|---|
| Cosmos SDK | `v0.53.7` |
| Go | `1.25.12` |
| CometBFT | `v0.38.21` |
| Node.js | `22.x LTS` |
| PostgreSQL | `16.x` |
| Redis | `7.x` optional |

---

## 3. MacBook 로컬 요구사항

| Tool | Required | Notes |
|---|---:|---|
| Docker Desktop | Yes | Docker engine and compose |
| Git | Yes | Clone/pull repository |
| Go local install | No | Provided by Docker image |
| Node local install | No | Frontend can later be containerized |
| PostgreSQL local install | No | Provided by Docker compose |
| Redis local install | No | Provided by Docker compose |

---

## 4. Repository Clone

```bash
git clone https://github.com/nus-gang/stable-test.git
cd stable-test
```

---

## 5. Chain Development Container

Build the Go/Cosmos SDK development image:

```bash
docker compose -f infra/docker/docker-compose.chain.yml build chain-dev
```

Open a shell inside the chain development container:

```bash
docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev
```

Inside the container:

```bash
go version
cd chain
```

Expected Go baseline:

```text
go1.25.12
```

---

## 6. Development DB/Redis

Start PostgreSQL and Redis:

```bash
docker compose -f infra/docker/docker-compose.dev.yml up -d
```

Stop them:

```bash
docker compose -f infra/docker/docker-compose.dev.yml down
```

Remove volumes if needed:

```bash
docker compose -f infra/docker/docker-compose.dev.yml down -v
```

---

## 7. Chain Build Flow

After the Cosmos SDK scaffold is generated in `chain/`, use:

```bash
docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev chain/scripts/build.sh
```

Current behavior before scaffold:

```text
chain/go.mod not found. Generate the Cosmos SDK scaffold in chain/ first.
```

This is expected until the chain app is generated.

---

## 8. Single Node Local Chain Flow

After the chain binary is built and available as `stablecoind`:

```bash
docker compose -f infra/docker/docker-compose.chain.yml run --rm \
  -e CHAIN_BINARY=stablecoind \
  -e CHAIN_ID=stablecoin-private-1 \
  chain-dev chain/scripts/start-single-node.sh
```

Ports exposed by `docker-compose.chain.yml`:

| Port | Service |
|---:|---|
| `26656` | P2P |
| `26657` | CometBFT RPC |
| `1317` | Cosmos REST API |
| `9090` | Cosmos gRPC |

---

## 9. 4-Validator Devnet Flow

The 4-validator compose file is scaffold-ready:

```bash
docker compose -f infra/docker/docker-compose.devnet.yml up --build
```

Before the chain binary exists, validator containers will wait and print a message.

After scaffold, the devnet script must be completed with:

1. Shared genesis generation
2. Validator key creation
3. Genesis account allocation
4. Gentx creation
5. `collect-gentxs`
6. Persistent peer configuration
7. USDX genesis policy injection

---

## 10. Apple Silicon Notes

Apple Silicon Macs should use native `linux/arm64` Docker images where possible.

The current Dockerfiles use official multi-architecture images:

```text
golang:1.25.12-bookworm
postgres:16-alpine
redis:7-alpine
```

These should run on both Apple Silicon and Intel Macs.

If a dependency later requires amd64, use Docker platform override only for that specific service.

---

## 11. Useful Commands

```bash
# Check repository skeleton
./scripts/check_repo.sh

# Build chain dev image
docker compose -f infra/docker/docker-compose.chain.yml build chain-dev

# Open chain dev shell
docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev

# Start DB/Redis
docker compose -f infra/docker/docker-compose.dev.yml up -d

# Stop DB/Redis
docker compose -f infra/docker/docker-compose.dev.yml down

# Start scaffold-ready devnet
docker compose -f infra/docker/docker-compose.devnet.yml up --build
```

---

## 12. 다음 구현 작업

Docker 기반 개발환경 다음 작업은 다음 순서로 진행한다.

| Order | Task |
|---:|---|
| 1 | Cosmos SDK `v0.53.7` scaffold를 `chain/`에 생성 |
| 2 | `stablecoind` binary build 확인 |
| 3 | `start-single-node.sh`를 실제 genesis flow에 맞게 완성 |
| 4 | 4-validator devnet genesis/gentx 자동화 |
| 5 | `x/authority` module scaffold |
| 6 | `x/stablecoin` module scaffold |

## Cosmos SDK Scaffold 생성

Docker 이미지 빌드 후 `chain-dev` 컨테이너 안에서 아래 명령을 실행합니다.

```bash
chain/scripts/scaffold-chain.sh
```

이 스크립트는 Ignite CLI를 사용해 임시 디렉터리에 Cosmos SDK app scaffold를 생성한 뒤 `chain/`으로 병합합니다. 기본값은 다음과 같습니다.

| 항목 | 값 |
|---|---|
| Chain name | `stablecoin` |
| Binary | `stablecoind` |
| Chain ID | `stablecoin-private-1` |
| Address prefix | `stbc` |
| Default denom | `uusdx` |
| Cosmos SDK | `v0.53.7` |

생성 후 빌드합니다.

```bash
chain/scripts/build.sh
```

## Current Go 기준

현재 chain 개발 Docker image는 `golang:1.25.12-bookworm`을 직접 사용합니다. 이전의 `Go 1.23.2 + scaffold-only Go helper + go wrapper` 구조는 제거되었습니다.

| 항목 | 값 |
|---|---|
| Project Go baseline | `1.25.12` |
| Docker base image | `golang:1.25.12-bookworm` |
| Cosmos SDK target | `v0.53.7` |
| Ignite CLI | `v29.10.1` |

이미 이전 이미지가 있다면 반드시 no-cache로 다시 빌드합니다.

```bash
docker compose -f infra/docker/docker-compose.chain.yml build --no-cache chain-dev
```

## Troubleshooting: Ignite relative path scaffold error

If scaffold fails with:

```text
Find relative path /workspace : Rel: can't make stablecoin relative to /workspace
```

Update to the latest `main` branch and rerun the scaffold script. The script now runs Ignite from the repository root and passes an explicit repo-relative `--path .tmp/stablecoin`, avoiding Ignite v29.10.x relative path resolution issues.

```bash
git pull origin main
rm -rf .tmp/stablecoin
chain/scripts/scaffold-chain.sh
```


### Ignite OpenAPI generation memory note

Proto/OpenAPI generation is enabled by default during scaffold. Before running it on Docker Desktop for Mac, allocate enough resources: 8GB memory minimum, 12~16GB recommended, and 4GB+ swap. If scaffold fails while generating an OpenAPI spec with `signal: killed`, either increase Docker Desktop memory and retry, or use the fallback mode:

```bash
SKIP_PROTO=1 chain/scripts/scaffold-chain.sh
```


## Docker Desktop resource recommendation for proto/OpenAPI generation

Proto/OpenAPI generation is enabled by default. Configure Docker Desktop resources before running the scaffold:

| Resource | Minimum | Recommended |
|---|---:|---:|
| Memory | 8GB | 12GB ~ 16GB |
| CPU | 4 cores | 6 ~ 8 cores |
| Swap | 4GB | 4GB ~ 8GB |
| Disk image size | 64GB | 100GB+ |

If OpenAPI generation is killed by the OS, retry after increasing Docker memory or run `SKIP_PROTO=1 chain/scripts/scaffold-chain.sh` as a fallback.


### Local chain minimum gas price

`chain/scripts/start-single-node.sh` automatically sets `minimum-gas-prices` in `app.toml`. The local default is `0uusdx`. Override it when needed:

```bash
MIN_GAS_PRICES=0.001uusdx chain/scripts/start-single-node.sh
```
