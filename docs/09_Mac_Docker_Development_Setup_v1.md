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
| Go | `1.23.2` |
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
go1.23.2
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
golang:1.23.2-bookworm
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
