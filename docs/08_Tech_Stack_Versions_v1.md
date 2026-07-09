# Tech Stack Versions v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 MVP 개발 착수를 위한 핵심 기술 스택 버전을 확정한다.

특히 다음 항목을 확정한다.

- Cosmos SDK version
- Go version
- CometBFT version
- Node.js version 기준
- 버전 선택 이유
- 향후 업그레이드 정책

---

## 2. 최종 확정 버전

| 영역 | 확정 버전 | 상태 |
|---|---|---|
| Cosmos SDK | `v0.53.7` | MVP 개발 기준 확정 |
| Go | `1.25.12` | MVP Docker/CI/build 기준 |
| CometBFT | `v0.38.21` | Cosmos SDK `v0.53.7` dependency 기준 |
| Node.js | `22.x LTS` | Wallet/Scan/Admin/API 개발 기준 |
| PostgreSQL | `16.x` | Indexer/API DB 기준 |
| Redis | `7.x` | Cache/queue optional 기준 |

---

## 3. Cosmos SDK 버전 결정

## 3.1 선택 버전

MVP 개발 기준 Cosmos SDK 버전은 다음으로 확정한다.

```text
Cosmos SDK: v0.53.7
```

## 3.2 선택 이유

| 기준 | 판단 |
|---|---|
| 안정성 | `v0.53` 계열은 현재 production chain에서 많이 사용되는 안정 계열로 판단 |
| 최신 패치 | `v0.53.7`은 `v0.53` 계열의 최신 패치 버전으로 확인 |
| Go 요구사항 | `go 1.25.12` 기준으로 개발 환경 구성이 현실적 |
| CometBFT 호환성 | `CometBFT v0.38.21`과 함께 사용됨 |
| MVP 적합성 | private chain MVP에 필요한 기능 구현에 충분 |
| 리스크 | `v0.54` 대비 급격한 최신 Go 요구사항과 breaking change 리스크가 낮음 |

---

## 4. 비교 검토

## 4.1 Cosmos SDK v0.53.7

확인된 주요 정보:

```text
Cosmos SDK: v0.53.7
Go directive: go 1.25.12
CometBFT: github.com/cometbft/cometbft v0.38.21
cosmossdk.io/api: v0.9.2
cosmossdk.io/core: v0.11.3
cosmossdk.io/math: v1.5.3
cosmossdk.io/store: v1.1.2
```

## 4.2 Cosmos SDK v0.54.x

확인된 주요 정보:

```text
Cosmos SDK v0.54.2 go directive: go 1.25.9
```

`v0.54` 계열은 최신 계열이지만, MVP 착수 시점에서는 다음 이유로 보류한다.

| 항목 | 판단 |
|---|---|
| Go version | `1.25.9` 요구로 개발/CI 환경 부담 증가 |
| 생태계 호환성 | 일부 도구, 예제, third-party integration의 v0.53 대비 검증 필요 |
| MVP 속도 | stablecoin private chain MVP에는 v0.53.7이 충분 |
| 업그레이드 전략 | MVP 이후 안정화 단계에서 v0.54 계열 재검토 |

---

## 5. Go 버전 결정

## 5.1 확정 버전

```text
Go: 1.25.12
```

## 5.2 정책

- `chain/` 구현, Docker 개발환경, CI/release build는 Go `1.25.12`를 기준으로 한다.
- 개발자 로컬, CI, Docker build image는 동일한 Go 버전을 사용한다.
- 추후 Cosmos SDK 업그레이드 시 Go 버전도 함께 재검토한다.

## 5.3 로컬 환경 참고

현재 작업 컨테이너에서는 `go version`이 확인되지 않았다. 따라서 실제 개발 착수 전 다음 중 하나로 Go 환경을 구성해야 한다.

| 방식 | 설명 | 추천 |
|---|---|---:|
| Docker 기반 | Go 1.25.12 build image 사용 | 높음 |
| asdf | `.tool-versions` 기준 설치 | 높음 |
| mise | `mise.toml` 기준 설치 | 중간 |
| 시스템 설치 | OS package 또는 공식 tarball | 중간 |

---

## 6. Node.js 버전 결정

Wallet, Scan, Admin, API 개발 기준은 다음으로 둔다.

```text
Node.js: 22.x LTS
```

현재 작업 환경에서 확인된 Node.js 버전:

```text
Node.js: v22.22.0
```

정책:

- Frontend와 TypeScript backend는 Node.js 22 LTS 기준으로 개발한다.
- Package manager는 추후 `pnpm` 또는 `npm` 중 확정한다.
- MVP 초기에는 package manager 결정 전 skeleton만 유지한다.

---

## 7. Database / Infra 버전

MVP indexer/API 개발 기준:

| 구성요소 | 버전 | 비고 |
|---|---|---|
| PostgreSQL | `16.x` | `infra/docker/docker-compose.dev.yml` 기준 |
| Redis | `7.x` | optional cache/queue |
| Docker Compose | 최신 v2 계열 | local devnet/dev service 실행 |

---

## 8. 구현 착수 기준

Phase 1 개발은 다음 버전을 기준으로 시작한다.

```text
Cosmos SDK: v0.53.7
Go: 1.25.12
CometBFT: v0.38.21
Node.js: 22.x LTS
PostgreSQL: 16.x
Redis: 7.x
```

---

## 9. Repository 반영 사항

본 결정에 따라 다음 파일 또는 설정에 버전을 반영한다.

| 파일 | 반영 내용 |
|---|---|
| `README.md` | 확정 기술 스택 요약 추가 |
| `docs/00_Documentation_Index.md` | 본 문서 링크 추가 |
| `docs/backlog/Initial_Backlog_v1.md` | version lock 관련 task 상태 업데이트 |
| `.tool-versions` | Go/Node 기준 버전 기록 |
| `chain/README.md` | Cosmos SDK/Go/CometBFT 기준 명시 |

---

## 10. 업그레이드 정책

| 시점 | 정책 |
|---|---|
| MVP 개발 중 | Cosmos SDK `v0.53.7` 유지 |
| MVP 완료 후 | `v0.54.x` 안정성, tooling, migration path 재검토 |
| Pilot 전 | security patch 확인 후 `v0.53.x` 최신 패치 또는 `v0.54.x` 이전 결정 |
| Production 전 | 별도 upgrade plan과 migration rehearsal 필수 |

---

## 11. 최종 결정

MVP 개발 착수 기준 기술 스택은 다음으로 확정한다.

```text
Cosmos SDK v0.53.7
Go 1.25.12
CometBFT v0.38.21
Node.js 22.x LTS
PostgreSQL 16.x
Redis 7.x optional
```

이 버전을 기준으로 다음 작업은 `chain/` Cosmos SDK app scaffold 생성이다.
