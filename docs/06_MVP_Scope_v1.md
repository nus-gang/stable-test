# Private Cosmos Stablecoin Platform MVP Scope v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 **실제 개발 착수 기준이 되는 MVP 범위**를 정의한다.

이 문서는 다음 결정을 명확히 한다.

- MVP에 반드시 포함할 기능
- MVP에서 제외하고 이후 Phase로 넘길 기능
- Chain, Wallet, Scan, Admin, Indexer/API별 최소 개발 범위
- 개발 완료 판단 기준
- 우선순위와 의존성

---

## 2. MVP 정의

본 프로젝트의 MVP는 다음 상태를 목표로 한다.

```text
Private Cosmos validator network 위에서 USDX stablecoin을 생성하고,
권한 주소가 mint/burn을 실행하며,
사용자가 Wallet에서 USDX를 송금하고,
Scan에서 block/tx/address/token 정보를 조회하고,
Admin에서 mint/burn, blacklist/freeze, fee 설정을 관리할 수 있는 상태.
```

즉 MVP의 핵심은 **스테이블코인의 발행, 소각, 전송, 조회, 기본 운영 관리가 end-to-end로 동작하는 것**이다.

---

## 3. MVP 핵심 원칙

| 원칙 | 설명 |
|---|---|
| Chain first, but not chain only | 체인 기능을 먼저 만들되 Wallet/Scan/Admin과 빠르게 연결한다. |
| End-to-end 우선 | 개별 기능 완성보다 발행 → 송금 → 조회 → 관리 흐름 완성을 우선한다. |
| Compliance는 구조만 포함 | 초기에는 KYC/AML 강제가 아니라 `BLACKLIST_ONLY` 모드로 시작한다. |
| Multi-stablecoin 확장 가능 구조 | MVP에서는 USDX 중심이지만 GBPX/EURX 추가가 가능한 registry 구조로 만든다. |
| 권한 기반 운영 | mint/burn/admin action은 권한 주소만 실행 가능해야 한다. |
| 감사 가능성 | 주요 운영 액션은 event/audit log로 추적 가능해야 한다. |
| 단순한 UX | MVP Wallet은 복잡한 DeFi 기능보다 송금과 잔액 확인에 집중한다. |

---

## 4. MVP 포함 범위 요약

| 제품 영역 | MVP 포함 여부 | 핵심 범위 |
|---|---:|---|
| Private Cosmos Chain | 포함 | validator network, stablecoin, mint/burn, compliance, fee, audit |
| Indexer/API | 포함 | block/tx/event indexing, wallet/scan/admin API |
| Web Wallet | 포함 | 계정 생성/복구, 잔액 조회, 송금, fee denom 선택, tx history |
| Scan / Explorer | 포함 | block, tx, address, token, mint/burn 조회 |
| Admin Backoffice | 포함 | stablecoin, mint/burn, blacklist/freeze, fee, role 기본 관리 |
| Swap | 제외 | Phase 2 또는 Phase 3로 이관 |
| Fee Delegation | 제외 또는 제한 | Phase 3, 단 chain 설계는 확장 가능하게 유지 |
| Multisig UI | 제외 또는 제한 | Phase 3, MVP에서는 Cosmos CLI multisig 또는 임시 운영 방식 허용 |
| Reserve / Oracle | 제외 | Phase 4 |
| Full KYC/AML | 제외 | MVP에서는 `BLACKLIST_ONLY` |
| Mobile Wallet | 제외 | MVP 이후 |
| IBC | 제외 | private chain 안정화 후 검토 |

---

# 5. Chain MVP Scope

## 5.1 Chain 기본 요구사항

| 항목 | MVP 기준 |
|---|---|
| Chain type | Cosmos SDK 기반 private permissioned chain |
| Consensus | CometBFT |
| Initial validator count | 4개 local/devnet 기준 |
| Chain ID | `stablecoin-private-1` |
| Initial stablecoin | USDX |
| Base denom | `uusdx` |
| Decimals | 6 |
| Compliance mode | `BLACKLIST_ONLY` |
| Fee token | `uusdx` 우선 허용 |
| Fee collector | treasury 주소로 수수료 수취 |

---

## 5.2 MVP 필수 Chain Modules

| 모듈 | MVP 포함 기능 |
|---|---|
| `x/authority` | role grant/revoke, role query, 권한 검증 |
| `x/stablecoin` | stablecoin 생성, 조회, mint, burn, pause/resume |
| `x/compliance` | compliance mode, blacklist, freeze, transfer restriction |
| `x/feehandler` | allowed fee denom, fee collector 설정, fee event |
| `x/audit` | 중요 운영 액션 event/audit 기록 |

---

## 5.3 MVP 선택 Chain Modules

| 모듈 | MVP 처리 방식 |
|---|---|
| `x/validatorauthority` | 기본 구조 또는 stub 가능. 실제 50% 투표 로직은 Phase 3 가능 |
| `x/stableswap` | MVP 제외 |
| `x/reserve` | MVP 제외, interface만 고려 |
| `x/oracle` | MVP 제외 |

---

## 5.4 Chain MVP 상세 기능

### 5.4.1 `x/authority`

MVP 기능:

| 기능 | 설명 |
|---|---|
| Role 등록 | genesis 또는 admin tx로 role 부여 |
| Role 회수 | 권한 주소에서 role 제거 |
| Role 조회 | 주소별 role 확인 |
| 권한 체크 | mint/burn/admin action 실행 전 권한 검증 |

MVP Role:

| Role | 설명 |
|---|---|
| `SUPER_ADMIN` | 전체 최고 권한 |
| `STABLECOIN_ADMIN` | stablecoin 생성/수정/중지 |
| `MINTER` | USDX 발행 |
| `BURNER` | USDX 소각 |
| `COMPLIANCE_ADMIN` | blacklist/freeze 관리 |
| `FEE_ADMIN` | fee denom/collector 설정 |
| `AUDITOR` | 감사 조회 권한 optional |

---

### 5.4.2 `x/stablecoin`

MVP 기능:

| 기능 | 설명 |
|---|---|
| Stablecoin 생성 | USDX stablecoin 등록 |
| Stablecoin 조회 | denom별 정보 조회 |
| Mint | 권한 주소만 발행 가능 |
| Burn | 권한 주소만 소각 가능 |
| Pause | stablecoin 기능 일시 중지 |
| Resume | 일시 중지 해제 |
| Supply 조회 | 총 발행량 조회 |

MVP token:

| 항목 | 값 |
|---|---|
| Display denom | USDX |
| Base denom | `uusdx` |
| Fiat currency | USD |
| Decimals | 6 |
| Initial supply | 0 |
| Mint authority | `MINTER` role |
| Burn authority | `BURNER` role |

---

### 5.4.3 `x/compliance`

MVP 기능:

| 기능 | 설명 |
|---|---|
| Compliance mode 설정 | MVP 기본 `BLACKLIST_ONLY` |
| Blacklist address | 주소 차단 |
| Remove blacklist | 주소 차단 해제 |
| Freeze address | 주소 동결 |
| Unfreeze address | 동결 해제 |
| Transfer check | 송금 전 sender/receiver 상태 확인 |

MVP policy:

```text
mode = BLACKLIST_ONLY
kyc_required = false
aml_required = false
whitelist_required = false
blacklist_enabled = true
freeze_enabled = true
```

Transfer rule:

```text
if sender is blacklisted: reject
if receiver is blacklisted: reject
if sender is frozen: reject
if receiver is frozen: reject
otherwise: allow
```

---

### 5.4.4 `x/feehandler`

MVP 기능:

| 기능 | 설명 |
|---|---|
| Allowed fee denom 설정 | MVP에서는 `uusdx` 우선 |
| Fee collector 설정 | treasury 주소 지정 |
| Fee event 기록 | 수수료 수취 이벤트 발생 |
| Fee denom 조회 | Wallet/Admin에서 조회 가능 |

MVP 기준:

- `uusdx`로 transaction fee 지불 가능해야 한다.
- 수수료는 지정 treasury 주소 또는 fee collector module account를 통해 treasury로 이동해야 한다.
- fee policy 변경은 `FEE_ADMIN` 권한이 필요하다.

---

### 5.4.5 `x/audit`

MVP audit 대상:

| 이벤트 | 설명 |
|---|---|
| stablecoin created | stablecoin 생성 |
| stablecoin minted | 발행 |
| stablecoin burned | 소각 |
| stablecoin paused/resumed | 중지/재개 |
| address blacklisted | blacklist 등록 |
| address frozen | freeze 등록 |
| role granted/revoked | 권한 변경 |
| fee collector updated | 수수료 주소 변경 |

---

# 6. Indexer/API MVP Scope

## 6.1 Indexer MVP 기능

| 기능 | 설명 |
|---|---|
| Block indexing | block height, hash, timestamp, proposer 저장 |
| Tx indexing | tx hash, status, height, fee, signer 저장 |
| Message parsing | msg type별 데이터 저장 |
| Event parsing | stablecoin/compliance/fee/audit event 파싱 |
| Address tx history | 주소별 transaction 조회 가능 |
| Token cache | stablecoin registry와 supply cache |
| Mint/Burn history | 발행/소각 이벤트 저장 |

---

## 6.2 API MVP Endpoints

| Endpoint | 용도 |
|---|---|
| `GET /health` | API 상태 확인 |
| `GET /blocks` | block list |
| `GET /blocks/:height` | block detail |
| `GET /txs/:hash` | transaction detail |
| `GET /addresses/:address` | address summary |
| `GET /addresses/:address/txs` | address tx history |
| `GET /balances/:address` | address balance |
| `GET /stablecoins` | stablecoin list |
| `GET /stablecoins/:denom` | stablecoin detail |
| `GET /mint-burns` | mint/burn history |
| `GET /fees/config` | fee config 조회 |

---

# 7. Wallet MVP Scope

## 7.1 Wallet MVP 기능

| 기능 | MVP 포함 | 설명 |
|---|---:|---|
| 새 지갑 생성 | 포함 | mnemonic 기반 |
| 지갑 복구 | 포함 | seed phrase import |
| 주소 표시/복사 | 포함 | QR optional |
| 잔액 조회 | 포함 | USDX balance 조회 |
| 토큰 목록 | 포함 | registry 기반 표시 |
| 송금 | 포함 | USDX 전송 |
| Fee denom 선택 | 포함 | MVP에서는 `uusdx` |
| Tx history | 포함 | indexer API 기반 |
| Compliance 상태 표시 | 포함 | Transfer Enabled/Restricted 정도 |
| Swap | 제외 | Phase 3 |
| Fee delegation | 제외 | Phase 3 |
| Multisig UI | 제외 | Phase 3 |

---

## 7.2 Wallet MVP 화면

| 화면 | 기능 |
|---|---|
| Onboarding | 지갑 생성/복구 |
| Dashboard | 주소, USDX 잔액, 최근 거래 |
| Send | 수신 주소, 금액, fee, tx preview, send |
| Receive | 주소/QR 표시 |
| Transaction History | 거래 내역 조회 |
| Transaction Detail | tx hash, status, fee, messages |
| Settings | RPC/API endpoint, network info |

---

# 8. Scan MVP Scope

## 8.1 Scan MVP 기능

| 기능 | MVP 포함 | 설명 |
|---|---:|---|
| Home dashboard | 포함 | latest blocks/txs |
| Block list/detail | 포함 | block 정보 조회 |
| Tx detail | 포함 | tx hash/status/msg/event |
| Address detail | 포함 | balance, tx history |
| Token detail | 포함 | USDX supply, config |
| Mint/Burn history | 포함 | 발행/소각 내역 |
| Validator list | 포함 | active validator 목록 |
| Fee history | 선택 | MVP 후반 가능 |
| Compliance detail | 제한 | 공개 scan에는 상세 노출 금지 |
| Admin action detail | 선택 | audit 화면은 Admin 우선 |

---

## 8.2 Scan MVP 화면

| 화면 | 기능 |
|---|---|
| Home | latest blocks, latest txs, chain summary |
| Blocks | block list/detail |
| Transactions | tx search/detail |
| Address | balance, tx history |
| Token | stablecoin info, supply, mint/burn |
| Validators | validator list/status |

---

# 9. Admin MVP Scope

## 9.1 Admin MVP 기능

| 기능 | MVP 포함 | 설명 |
|---|---:|---|
| Admin login | 포함 | 초기에는 basic auth 또는 internal auth 가능 |
| Dashboard | 포함 | chain status, supply, recent actions |
| Stablecoin 조회 | 포함 | USDX 정보 조회 |
| Stablecoin 생성 | 포함 | 개발/운영 환경에서 USDX 등록 |
| Mint | 포함 | 권한 주소로 USDX 발행 |
| Burn | 포함 | 권한 주소로 USDX 소각 |
| Blacklist 관리 | 포함 | 주소 차단/해제 |
| Freeze 관리 | 포함 | 주소 동결/해제 |
| Fee config 관리 | 포함 | fee denom, collector 설정 |
| Role 조회 | 포함 | 주소별 role 확인 |
| Role 부여/회수 | 선택 | MVP 후반 또는 CLI 우선 가능 |
| Audit log 조회 | 포함 | 주요 운영 이벤트 조회 |
| Swap 관리 | 제외 | Phase 3 |
| Validator 투표 관리 | 제외 | Phase 3 |
| KYC/AML workflow | 제외 | Phase 4 |

---

## 9.2 Admin MVP 화면

| 화면 | 기능 |
|---|---|
| Dashboard | chain status, token supply, recent admin actions |
| Stablecoins | USDX config, supply, pause/resume |
| Mint/Burn | 발행/소각 요청 및 실행 |
| Compliance | blacklist/freeze 관리 |
| Fees | allowed fee denom, collector address |
| Roles | role 조회, optional grant/revoke |
| Audit Logs | 운영 액션 조회 |

---

# 10. MVP 제외 범위

다음 기능은 MVP에서 제외하고 이후 단계에서 구현한다.

| 기능 | 이관 Phase | 이유 |
|---|---|---|
| GBPX/EURX production support | Phase 2 | registry 구조는 만들되 MVP 운영은 USDX 중심 |
| Stablecoin swap | Phase 3 | MVP 핵심 흐름 이후 구현 |
| Fee delegation | Phase 3 | wallet/admin UX와 policy 추가 필요 |
| Multisig web workflow | Phase 3 | MVP에서는 CLI 또는 운영 정책으로 대체 가능 |
| Validator 50% 투표 관리 UI | Phase 3 | 초기 devnet은 genesis/운영자 관리 가능 |
| Super admin force add/remove UI | Phase 3 | 위험 기능이므로 후순위 |
| Reserve attestation | Phase 4 | 준비금/감사 체계 확정 후 구현 |
| FX oracle | Phase 4 | swap 정교화 단계에서 필요 |
| Full KYC/AML workflow | Phase 4 | 초기에는 blacklist-only |
| Mobile wallet | Post-MVP | Web wallet 안정화 후 |
| IBC | Post-MVP | private chain 안정화 후 검토 |

---

# 11. MVP 완료 기준

## 11.1 Chain 완료 기준

| 기준 | 검증 방법 |
|---|---|
| 4-validator devnet 실행 | block 생성 및 validator status 확인 |
| USDX 생성 가능 | CLI/API query로 registry 확인 |
| 권한 주소만 mint 가능 | 권한/비권한 주소 테스트 |
| 권한 주소만 burn 가능 | 권한/비권한 주소 테스트 |
| 일반 송금 가능 | Wallet 또는 CLI transfer 테스트 |
| blacklist 주소 송금 차단 | blacklisted sender/receiver tx 실패 확인 |
| frozen 주소 송금 차단 | frozen sender/receiver tx 실패 확인 |
| fee collector 동작 | treasury balance 또는 fee event 확인 |
| audit event 발생 | indexer/event query 확인 |

---

## 11.2 Wallet 완료 기준

| 기준 | 검증 방법 |
|---|---|
| 지갑 생성/복구 가능 | mnemonic 생성/import 테스트 |
| USDX 잔액 표시 | chain balance와 Wallet 표시 비교 |
| USDX 송금 가능 | 송금 후 tx success 및 잔액 변경 확인 |
| fee denom 표시 | allowed fee denom 조회 표시 |
| tx history 표시 | indexer tx history와 일치 확인 |
| 제한 주소 오류 표시 | blacklist/freeze tx 실패 사유 표시 |

---

## 11.3 Scan 완료 기준

| 기준 | 검증 방법 |
|---|---|
| 최신 block 표시 | chain height와 일치 |
| tx detail 표시 | tx hash 검색 가능 |
| address balance 표시 | chain balance와 일치 |
| token supply 표시 | chain supply와 일치 |
| mint/burn history 표시 | event와 일치 |
| validator list 표시 | chain validator set과 일치 |

---

## 11.4 Admin 완료 기준

| 기준 | 검증 방법 |
|---|---|
| USDX 정보 조회 | chain registry와 일치 |
| mint 실행 | tx success 및 balance 증가 |
| burn 실행 | tx success 및 supply 감소 |
| blacklist/freeze 실행 | 이후 tx 차단 확인 |
| fee collector 변경 | fee config query 확인 |
| audit log 조회 | admin action event 표시 |

---

# 12. MVP 개발 우선순위

## Priority 0 — 반드시 필요

| 항목 | 설명 |
|---|---|
| Chain scaffold | 블록 생성 가능한 기본 체인 |
| Private devnet | 4-validator local/dev environment |
| `x/authority` | 권한 모델 |
| `x/stablecoin` | USDX create/mint/burn |
| `x/compliance` | blacklist/freeze |
| `x/feehandler` | fee denom/collector |
| Basic indexer | block/tx/event |
| Wallet send | USDX 송금 |
| Scan tx/address | 조회 기능 |
| Admin mint/blacklist | 운영 기능 |

## Priority 1 — MVP 완성도 향상

| 항목 | 설명 |
|---|---|
| Audit log UI | 운영 이력 조회 |
| Token detail | supply/mint/burn 표시 |
| Fee config UI | fee 정책 관리 |
| Pause/resume | stablecoin emergency control |
| Test automation | chain module integration tests |

## Priority 2 — MVP 이후

| 항목 | 설명 |
|---|---|
| Swap | USDX/GBPX 등 교환 |
| Fee delegation | 수수료 대납 |
| Multisig workflow | 기관용 승인 |
| Reserve/oracle | 준비금/환율 |
| Advanced compliance | KYC/AML required |

---

# 13. 개발 착수 체크리스트

개발 시작 전 다음 값이 확정되어야 한다.

| 항목 | 상태 | 비고 |
|---|---|---|
| Chain ID | 확정 필요 | `stablecoin-private-1` 제안 |
| Initial token | 확정 필요 | `USDX` 제안 |
| Base denom | 확정 필요 | `uusdx` 제안 |
| Decimals | 확정 필요 | `6` 제안 |
| Validator count | 확정 필요 | 4 제안 |
| Compliance mode | 확정 필요 | `BLACKLIST_ONLY` 제안 |
| Fee collector policy | 확정 필요 | treasury address |
| Admin role set | 확정 필요 | SUPER_ADMIN, MINTER 등 |
| Repo structure | 확정 필요 | mono-repo 제안 |
| Cosmos SDK version | 확정 필요 | 구현 착수 전 lock 필요 |
| Go/Node versions | 확정 필요 | CI/CD 기준 |

---

# 14. MVP 최종 성공 정의

MVP는 다음 데모가 끊김 없이 가능하면 성공으로 본다.

```text
1. Admin이 USDX stablecoin을 생성한다.
2. Minter가 사용자 A에게 1,000 USDX를 발행한다.
3. Wallet에서 사용자 A가 사용자 B에게 100 USDX를 송금한다.
4. 수수료는 USDX로 지불되고 treasury로 수취된다.
5. Scan에서 해당 block, tx, address balance, token supply를 조회한다.
6. Admin이 사용자 B를 blacklist 처리한다.
7. 사용자 B가 송금을 시도하면 tx가 실패한다.
8. Admin에서 blacklist/freeze/mint/burn/audit 내역을 조회한다.
```

이 흐름이 통과하면 MVP의 core value chain이 완성된 것으로 판단한다.
