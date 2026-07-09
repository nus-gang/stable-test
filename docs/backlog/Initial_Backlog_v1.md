# Initial Development Backlog v1

## 1. Backlog Purpose

본 문서는 실제 개발 착수를 위한 초기 작업 백로그이다.

우선순위 기준:

| Priority | Meaning |
|---|---|
| P0 | MVP 진행을 위해 반드시 필요한 작업 |
| P1 | MVP 완성도와 운영성을 높이는 작업 |
| P2 | MVP 이후 확장 작업 |

---

# Epic 0 — Repository & Engineering Foundation

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E0-001 | P0 | Mono-repo structure 생성 | `chain`, `indexer`, `api`, `wallet-web`, `scan-web`, `admin-web`, `infra`, `docs` 디렉터리 존재 |
| E0-002 | P0 | `.gitignore` 구성 | `.a0proj`, secrets, node_modules, chain local data 제외 |
| E0-003 | P0 | README 작성 | 프로젝트 목적, 구조, MVP 요약 포함 |
| E0-004 | P0 | Documentation index 작성 | 모든 설계 문서 링크 포함 |
| E0-005 | P0 | Development stack lock 문서화 | Cosmos SDK v0.53.7, Go 1.23.2, Node.js 22.x LTS 확정. Package manager는 추후 확정 |
| E0-006 | P1 | CI skeleton 추가 | lint/test placeholder workflow 추가 |

---

# Epic 1 — Chain Scaffold & Local Devnet

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E1-001 | P0 | Cosmos SDK version 확정 | v0.53.7로 확정, docs/08_Tech_Stack_Versions_v1.md 반영 |
| E1-002 | P0 | Go version 확정 | Go 1.23.2로 확정, .tool-versions 및 docs 반영 |
| E1-003 | P0 | Cosmos SDK app scaffold 생성 | `chain/`에서 daemon build 가능 |
| E1-004 | P0 | Address prefix `stbc` 설정 | account/validator prefix 확인 가능 |
| E1-005 | P0 | Chain ID `stablecoin-private-1` 설정 | local node status에서 확인 |
| E1-006 | P0 | Single-node localnet 실행 | block 생성 확인 |
| E1-007 | P0 | 4-validator devnet script 작성 | 4개 validator가 block 생성 |
| E1-008 | P1 | Devnet reset/start/stop scripts 작성 | repeatable local devnet lifecycle |

---

# Epic 2 — Authority Module MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E2-001 | P0 | `x/authority` module scaffold | module compile 및 genesis state 로드 |
| E2-002 | P0 | Role model 정의 | `SUPER_ADMIN`, `STABLECOIN_ADMIN`, `MINTER`, `BURNER`, `COMPLIANCE_ADMIN`, `FEE_ADMIN` 지원 |
| E2-003 | P0 | Genesis role assignment 구현 | genesis에서 role 초기화 가능 |
| E2-004 | P0 | `MsgGrantRole` 구현 | authorized signer만 role 부여 가능 |
| E2-005 | P0 | `MsgRevokeRole` 구현 | authorized signer만 role 회수 가능 |
| E2-006 | P0 | `QueryHasRole` 구현 | 주소/role 검증 query 가능 |
| E2-007 | P0 | 권한 체크 helper 구현 | 다른 모듈에서 재사용 가능 |
| E2-008 | P1 | role grant/revoke events 구현 | indexer에서 event 파싱 가능 |

---

# Epic 3 — Stablecoin Module MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E3-001 | P0 | `x/stablecoin` module scaffold | module compile 및 genesis state 로드 |
| E3-002 | P0 | Stablecoin registry state 구현 | denom/display/fiat/decimals/max_supply/paused 저장 |
| E3-003 | P0 | USDX genesis entry 구현 | `uusdx`, `USDX`, decimals 6 확인 |
| E3-004 | P0 | `MsgCreateStablecoin` 구현 | `STABLECOIN_ADMIN`만 생성 가능 |
| E3-005 | P0 | `MsgMintStablecoin` 구현 | `MINTER`만 mint 가능, balance 증가 |
| E3-006 | P0 | `MsgBurnStablecoin` 구현 | `BURNER`만 burn 가능, supply 감소 |
| E3-007 | P0 | `MsgPauseStablecoin` / `MsgResumeStablecoin` 구현 | paused 상태에서 제한 동작 확인 |
| E3-008 | P0 | supply query 구현 | denom별 supply 조회 가능 |
| E3-009 | P1 | mint/burn limit skeleton 구현 | Phase 2 확장 가능 구조 |
| E3-010 | P1 | stablecoin events 구현 | created/minted/burned/paused events 발생 |

---

# Epic 4 — Compliance Module MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E4-001 | P0 | `x/compliance` module scaffold | module compile 및 genesis state 로드 |
| E4-002 | P0 | Compliance mode state 구현 | `BYPASS`, `BLACKLIST_ONLY`, `WHITELIST_REQUIRED`, `KYC_AML_REQUIRED` 정의 |
| E4-003 | P0 | Genesis mode `BLACKLIST_ONLY` 설정 | query로 확인 가능 |
| E4-004 | P0 | blacklist add/remove 구현 | `COMPLIANCE_ADMIN`만 실행 가능 |
| E4-005 | P0 | freeze/unfreeze 구현 | `COMPLIANCE_ADMIN`만 실행 가능 |
| E4-006 | P0 | `CanTransfer` keeper method 구현 | sender/receiver 제한 판단 가능 |
| E4-007 | P0 | bank send restriction 또는 transfer hook 연동 | blacklisted/frozen 주소 송금 실패 |
| E4-008 | P1 | compliance events 구현 | blacklist/freeze events 발생 |

---

# Epic 5 — Fee Handler MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E5-001 | P0 | `x/feehandler` module scaffold | module compile 및 genesis state 로드 |
| E5-002 | P0 | allowed fee denom state 구현 | `uusdx` 허용 여부 query 가능 |
| E5-003 | P0 | fee collector state 구현 | treasury address query 가능 |
| E5-004 | P0 | fee denom validation 설계 | `uusdx` fee tx 허용 |
| E5-005 | P0 | fee routing 설계 구현 | fee collector 또는 treasury로 수수료 이동 확인 |
| E5-006 | P1 | fee events 구현 | fee collected/config updated events 발생 |

---

# Epic 6 — Audit/Event MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E6-001 | P0 | audit event schema 정의 | role/stablecoin/compliance/fee event 표준화 |
| E6-002 | P0 | chain events emit 확인 | tx result에서 이벤트 확인 가능 |
| E6-003 | P1 | `x/audit` state 저장 여부 결정 | MVP에서는 event+indexer 우선 |
| E6-004 | P1 | audit query/API 설계 | Admin audit log 조회 가능 |

---

# Epic 7 — Indexer/API MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E7-001 | P0 | Indexer service scaffold | 실행 가능한 서비스 skeleton |
| E7-002 | P0 | PostgreSQL schema 초안 작성 | blocks/txs/events/accounts/stablecoins 테이블 |
| E7-003 | P0 | block indexing 구현 | latest blocks 저장 |
| E7-004 | P0 | tx indexing 구현 | tx hash/status/message 저장 |
| E7-005 | P0 | custom event parser 구현 | stablecoin/compliance/fee events 파싱 |
| E7-006 | P0 | API service scaffold | `/health` 응답 |
| E7-007 | P0 | block/tx/address API 구현 | Scan/Wallet에서 조회 가능 |
| E7-008 | P0 | stablecoin API 구현 | token list/detail 조회 가능 |
| E7-009 | P1 | mint/burn history API 구현 | Admin/Scan에서 조회 가능 |

---

# Epic 8 — Wallet Web MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E8-001 | P0 | Wallet web scaffold | local dev server 실행 |
| E8-002 | P0 | mnemonic wallet 생성 | 새 주소 생성 가능 |
| E8-003 | P0 | wallet import 구현 | seed phrase import 가능 |
| E8-004 | P0 | balance 조회 | USDX balance 표시 |
| E8-005 | P0 | send tx 구현 | USDX 송금 성공 |
| E8-006 | P0 | fee denom 표시 | `uusdx` fee 선택/표시 |
| E8-007 | P0 | tx history 표시 | indexer API와 연동 |
| E8-008 | P1 | restricted address error UX | blacklist/freeze 실패 사유 표시 |

---

# Epic 9 — Scan Web MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E9-001 | P0 | Scan web scaffold | local dev server 실행 |
| E9-002 | P0 | Home dashboard 구현 | latest block/tx 표시 |
| E9-003 | P0 | Block list/detail 구현 | block 조회 가능 |
| E9-004 | P0 | Tx search/detail 구현 | tx hash 검색 가능 |
| E9-005 | P0 | Address detail 구현 | balance/tx history 표시 |
| E9-006 | P0 | Token detail 구현 | USDX supply/config 표시 |
| E9-007 | P1 | mint/burn history 화면 | event history 표시 |
| E9-008 | P1 | validator list 화면 | active validator 표시 |

---

# Epic 10 — Admin Web MVP

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E10-001 | P0 | Admin web scaffold | local dev server 실행 |
| E10-002 | P0 | Admin dashboard 구현 | chain status/supply/recent actions 표시 |
| E10-003 | P0 | Stablecoin management 화면 | USDX config 조회 |
| E10-004 | P0 | Mint 실행 UI | 권한 주소로 mint tx 성공 |
| E10-005 | P0 | Burn 실행 UI | 권한 주소로 burn tx 성공 |
| E10-006 | P0 | Blacklist/freeze UI | 제한 주소 설정 가능 |
| E10-007 | P0 | Fee config UI | fee collector/denom 조회 및 변경 |
| E10-008 | P1 | Role 조회/관리 UI | role query 및 grant/revoke optional |
| E10-009 | P1 | Audit log UI | admin action history 표시 |

---

# Epic 11 — MVP End-to-End Demo

| ID | Priority | Task | Acceptance Criteria |
|---|---|---|---|
| E11-001 | P0 | E2E demo script 작성 | demo 순서 문서화 |
| E11-002 | P0 | Admin creates/queries USDX | registry 확인 |
| E11-003 | P0 | Minter mints 1,000 USDX to User A | balance 증가 |
| E11-004 | P0 | User A sends 100 USDX to User B | tx success |
| E11-005 | P0 | Fee collected in treasury | fee 확인 |
| E11-006 | P0 | Scan shows tx/address/token | 조회 성공 |
| E11-007 | P0 | Admin blacklists User B | compliance state 변경 |
| E11-008 | P0 | User B transfer fails | expected failure 확인 |
| E11-009 | P0 | Audit log 확인 | admin actions 조회 가능 |

---

# Phase 2+ Backlog

| Feature | Priority | Notes |
|---|---|---|
| GBPX/EURX additional stablecoins | P2 | registry 확장 검증 |
| Stablecoin swap | P2 | `x/stableswap`, FX rate 필요 |
| Fee delegation | P2 | `x/feegrant` 또는 custom module |
| Multisig web workflow | P2 | institutional wallet |
| Validator authority voting | P2 | 50% 초과 합의 추가/삭제 |
| Super admin force add/remove | P2 | multisig/time-lock 권장 |
| Reserve attestation | P2 | `x/reserve` |
| Oracle / FX rate | P2 | `x/oracle` |
| Full KYC/AML workflow | P2 | offchain compliance DB 연동 |
