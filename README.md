# stable-test

# Stable Test — Private Cosmos Stablecoin Platform

Private Cosmos SDK 기반 permissioned stablecoin platform 프로젝트입니다.

## Product Scope

본 저장소는 다음 구성요소를 포함하는 mono-repo입니다.

| Component | Path | Purpose |
|---|---|---|
| Chain | `chain/` | Cosmos SDK private chain and custom modules |
| Indexer | `indexer/` | Block, transaction, and event indexing |
| API | `api/` | Wallet, Scan, and Admin service API |
| Wallet Web | `wallet-web/` | User/institution web wallet |
| Scan Web | `scan-web/` | Block explorer / scan service |
| Admin Web | `admin-web/` | Operator backoffice |
| Infra | `infra/` | Devnet, Docker, monitoring, deployment scripts |
| Docs | `docs/` | PRD, architecture, specifications, roadmap, backlog |

## MVP Summary

MVP 목표는 다음 end-to-end 흐름을 구현하는 것입니다.

1. Private Cosmos devnet 실행
2. USDX stablecoin 생성
3. 권한 주소의 mint/burn 실행
4. Wallet에서 USDX 송금
5. 수수료를 USDX로 지불하고 treasury로 수취
6. Scan에서 block/tx/address/token 조회
7. Admin에서 blacklist/freeze, mint/burn, fee 설정 관리

## Tech Stack Baseline

| Component | Version |
|---|---|
| Cosmos SDK | `v0.53.7` |
| Go | `1.23.2` |
| CometBFT | `v0.38.21` |
| Node.js | `22.x LTS` |
| PostgreSQL | `16.x` |
| Redis | `7.x` optional |

## Initial Genesis Policy

| Item | Value |
|---|---|
| Chain ID | `stablecoin-private-1` |
| Address Prefix | `stbc` |
| Initial Stablecoin | `USDX` |
| Base Denom | `uusdx` |
| Decimals | `6` |
| Initial Supply | `0` |
| Initial Validators | `4` |
| Compliance Mode | `BLACKLIST_ONLY` |
| Fee Denom | `uusdx` |


### Generate the Cosmos SDK chain scaffold

After entering the `chain-dev` container, generate the initial Cosmos SDK application scaffold:

```bash
chain/scripts/scaffold-chain.sh
```

The script uses Ignite CLI inside Docker, targets Cosmos SDK `v0.53.7`, address prefix `stbc`, default denom `uusdx`, and merges the generated app into `chain/`.

```bash
chain/scripts/build.sh
```

## Documentation

Start with:

- [`docs/00_Documentation_Index.md`](docs/00_Documentation_Index.md)
- [`docs/06_MVP_Scope_v1.md`](docs/06_MVP_Scope_v1.md)
- [`docs/07_Genesis_Policy_v1.md`](docs/07_Genesis_Policy_v1.md)
- [`docs/backlog/Initial_Backlog_v1.md`](docs/backlog/Initial_Backlog_v1.md)

## Repository Status

This repository currently contains project documentation and initial mono-repo skeleton. Actual implementation starts with the Phase 1 chain scaffold.

## Mac Docker Development

MacBook local development is Docker-based. Start with:

```bash
docker compose -f infra/docker/docker-compose.chain.yml build chain-dev

# If you are updating from an older image, rebuild without cache:
docker compose -f infra/docker/docker-compose.chain.yml build --no-cache chain-dev
docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev
```

Development DB/Redis:

```bash
docker compose -f infra/docker/docker-compose.dev.yml up -d
```

See [`docs/09_Mac_Docker_Development_Setup_v1.md`](docs/09_Mac_Docker_Development_Setup_v1.md) for the full setup guide.
