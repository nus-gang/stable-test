# infra

Infrastructure and local development tooling for Stable Test.

## Docker Files

| File | Purpose |
|---|---|
| `docker/Dockerfile.chain-dev` | Go 1.23.2 chain development image |
| `docker/docker-compose.chain.yml` | Interactive chain development container |
| `docker/docker-compose.dev.yml` | PostgreSQL 16 and Redis 7 for service development |
| `docker/docker-compose.devnet.yml` | Scaffold-ready 4-validator devnet skeleton |

## Quick Start

```bash
docker compose -f infra/docker/docker-compose.chain.yml build chain-dev
docker compose -f infra/docker/docker-compose.chain.yml run --rm chain-dev
```

See `../docs/09_Mac_Docker_Development_Setup_v1.md`.
