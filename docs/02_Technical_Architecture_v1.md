# Private Cosmos Stablecoin Platform Technical Architecture v1

## 1. 아키텍처 개요

본 플랫폼은 Cosmos SDK 기반 private permissioned chain과 이를 사용하는 Wallet, Scan, Admin Backoffice, Indexer/API layer로 구성된다.

```text
Users / Institutions
        |
        v
Wallet / Institutional Wallet
        |
        v
API Gateway / Wallet API
        |
        +-----------------------------+
        |                             |
        v                             v
Private Cosmos Chain              Backend Services
- x/stablecoin                    - KYC/AML offchain
- x/compliance                    - Treasury ops
- x/stableswap                    - Notification
- x/feehandler                    - Admin approval
- x/authority                     - Auth/session
- x/validatorauthority            - Reporting
- x/audit
        |
        v
RPC / gRPC / Events
        |
        v
Indexer Service
        |
        v
PostgreSQL / Redis
        |
        +-----------------------------+
        |                             |
        v                             v
Scan / Explorer                 Admin Backoffice
```

---

## 2. 시스템 구성요소

| 구성요소 | 설명 |
|---|---|
| Private Cosmos Chain | 핵심 원장, consensus, stablecoin business logic 실행 |
| CometBFT | BFT consensus engine |
| Validator Nodes | permissioned block producer set |
| Full Nodes | query/RPC 제공, indexing source |
| Wallet App | 사용자 및 기관 거래 인터페이스 |
| Scan / Explorer | 블록체인 데이터 조회 인터페이스 |
| Admin Backoffice | 운영자 관리 시스템 |
| Indexer | block/tx/event를 파싱해 DB에 저장 |
| API Gateway | Wallet/Scan/Admin이 사용하는 API 제공 |
| Offchain Compliance DB | 개인정보, KYC/AML 자료 등 민감 데이터 저장 |
| Monitoring | node, API, DB, chain 상태 모니터링 |

---

## 3. Chain Layer

### 3.1 기본 모듈

| 모듈 | 역할 |
|---|---|
| x/auth | 계정 및 서명 처리 |
| x/bank | balance, transfer 처리 |
| x/feegrant | 기본 fee delegation |
| x/gov | 선택적 governance 기능 |
| x/params | chain parameter 관리 |
| x/upgrade | chain upgrade 지원 |
| x/group | multisig/group policy 확장 시 사용 가능 |

### 3.2 커스텀 모듈

| 모듈 | 역할 |
|---|---|
| x/authority | role, permission, super admin 관리 |
| x/validatorauthority | validator 추가/삭제/강제추방 관리 |
| x/compliance | KYC/AML, whitelist, blacklist, freeze 정책 |
| x/stablecoin | multi-stablecoin registry, mint, burn, pause |
| x/stableswap | stablecoin 간 swap, rate, fee 관리 |
| x/feehandler | multi fee denom, fee collector, treasury routing |
| x/reserve | reserve attestation, supply-reserve report |
| x/oracle | FX rate 또는 운영자 고시 환율 관리 |
| x/audit | 중요 액션 감사 로그 |

---

## 4. Network Architecture

### 4.1 Private Validator Network

초기 네트워크 권장 구성:

| 노드 | 개수 | 설명 |
|---|---:|---|
| Validator Node | 4개 이상 | 합의 참여 |
| Full Node | 1~2개 이상 | RPC/gRPC/query 제공 |
| Sentry Node | 선택 | 외부 접근 분리 |
| Indexer Node | 1개 이상 | block/event indexing |
| Monitoring Node | 1개 | Prometheus/Grafana |

### 4.2 Validator 관리 정책

- validator set 변경은 `x/validatorauthority`를 통해 처리한다.
- 50% 초과 validator 동의 시 추가/삭제가 가능하다.
- super admin은 emergency case에서 강제 추가/추방 가능하다.
- 모든 변경은 event와 audit log로 남긴다.

---

## 5. Transaction 처리 흐름

### 5.1 일반 전송 흐름

```text
1. Wallet이 tx 생성
2. 사용자가 fee denom 선택
3. tx 서명
4. antehandler에서 fee 검증
5. x/compliance에서 sender/receiver 상태 검증
6. x/feehandler에서 fee routing
7. x/bank에서 stablecoin transfer 실행
8. x/audit 또는 event emit
9. Indexer가 tx/event 저장
10. Wallet/Scan에서 결과 조회
```

### 5.2 Mint 흐름

```text
1. Admin 또는 backend가 mint 요청 생성
2. minter 권한 주소 또는 multisig가 서명
3. x/authority가 권한 확인
4. x/stablecoin이 denom, limit, pause 상태 확인
5. x/reserve가 발행 가능 조건 확인 optional
6. stablecoin mint 후 대상 주소로 전송
7. audit event 발생
```

### 5.3 Swap 흐름

```text
1. Wallet이 swap quote 요청
2. x/stableswap 또는 API가 rate/fee 반환
3. 사용자가 swap tx 서명
4. compliance, fee, pair 상태 확인
5. input stablecoin 차감
6. swap fee treasury 전송
7. output stablecoin 지급
8. swap event 기록
```

### 5.4 Fee Delegation 흐름

```text
1. grantor가 grantee에게 fee allowance 부여
2. grantee가 tx 생성
3. fee payer를 grantor로 설정
4. antehandler 또는 feegrant가 allowance 확인
5. fee를 grantor balance에서 차감
6. tx 실행
```

---

## 6. Data Architecture

### 6.1 On-chain Data

| 데이터 | 저장 위치 |
|---|---|
| Account balance | x/bank |
| Stablecoin registry | x/stablecoin |
| Mint/burn history | event + x/audit optional |
| Compliance status | x/compliance |
| Validator change proposal/history | x/validatorauthority |
| Role/permission | x/authority |
| Swap pair/rate/fee | x/stableswap |
| Fee config | x/feehandler |
| Reserve report | x/reserve |

### 6.2 Off-chain Data

| 데이터 | 저장 위치 | 비고 |
|---|---|---|
| 개인정보 | Compliance DB | 온체인 저장 금지 |
| KYC 문서 | Secure storage | hash/reference만 온체인 가능 |
| AML 상세 결과 | Compliance DB | 관리자 전용 |
| Admin session | Backend DB | RBAC 적용 |
| Notification log | Backend DB | email/SMS/push 등 |

---

## 7. Indexer / API Architecture

### 7.1 Indexer Responsibilities

- block sync
- tx parsing
- event parsing
- custom module event decoding
- address balance cache
- token supply aggregation
- validator history indexing
- mint/burn/swap/fee history indexing
- admin/audit event indexing

### 7.2 Database 권장 스키마

| 테이블 | 설명 |
|---|---|
| blocks | block header, proposer, tx count |
| transactions | tx hash, height, status, fee, messages |
| messages | tx 내부 msg type별 데이터 |
| events | raw/decoded events |
| accounts | address metadata/cache |
| balances | address-denom balance cache |
| stablecoins | token registry cache |
| mint_burn_events | 발행/소각 이벤트 |
| swap_events | swap 이벤트 |
| fee_events | 수수료 이벤트 |
| validators | validator 현재 상태 |
| validator_events | validator 변경 이력 |
| authority_events | role 변경, super admin action |
| compliance_events | blacklist/freeze 등 관리자용 이벤트 |

---

## 8. Wallet Architecture

| 영역 | 설명 |
|---|---|
| Key Management | mnemonic/private key, 추후 hardware wallet/MPC 연동 |
| Chain Client | RPC/gRPC/REST 연결 |
| Tx Builder | custom module tx 생성 |
| Fee Selector | fee denom, fee payer 선택 |
| Compliance Precheck | 전송 전 address status 확인 |
| Token Registry | x/stablecoin registry 조회 |
| Multisig Flow | proposal, partial signature, broadcast |

---

## 9. Scan Architecture

Scan은 chain node를 직접 과부하시키지 않고 indexer DB/API를 사용한다.

| 화면 | 데이터 소스 |
|---|---|
| Home dashboard | Indexer API |
| Block detail | blocks, transactions |
| Tx detail | transactions, messages, events |
| Address detail | accounts, balances, transactions |
| Token detail | stablecoins, supply, mint/burn |
| Validator detail | validators, validator_events |
| Swap detail | swap_events |
| Fee dashboard | fee_events |

---

## 10. Admin Architecture

Admin Backoffice는 chain transaction을 직접 실행하는 운영 도구다.

| 기능 | Chain 연동 |
|---|---|
| Stablecoin 생성/수정 | x/stablecoin |
| Mint/Burn | x/stablecoin + x/authority |
| Blacklist/Freeze | x/compliance |
| Fee 설정 | x/feehandler |
| Swap pair/rate/fee | x/stableswap |
| Validator 관리 | x/validatorauthority |
| Role 관리 | x/authority |
| Reserve report | x/reserve |

---

## 11. Security Architecture

| 영역 | 요구사항 |
|---|---|
| Super Admin | multisig 필수 권장 |
| Treasury | multisig, MPC, HSM 고려 |
| Key Storage | private key 암호화, hardware signer 고려 |
| Admin Access | RBAC, MFA, audit log |
| Chain Upgrade | x/upgrade + governance/admin approval |
| Emergency Pause | stablecoin, swap, mint/burn pause 지원 |
| Monitoring | node health, block halt, abnormal tx 감지 |
| 개인정보 | 온체인 저장 금지 |

