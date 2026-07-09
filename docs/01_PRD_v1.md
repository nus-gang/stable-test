# Private Cosmos Stablecoin Platform PRD v1

## 1. 문서 목적

본 문서는 Cosmos SDK 기반 자체 private chain을 이용한 다중 스테이블코인 플랫폼의 제품 요구사항을 정의한다.

본 프로젝트는 단순 블록체인 노드 개발이 아니라 다음 제품군을 포함한다.

| 제품 | 역할 |
|---|---|
| Private Cosmos Chain | 스테이블코인 발행, 소각, 전송, 스왑, 수수료, validator, compliance 정책 실행 |
| Wallet | 사용자 및 기관의 자산 관리, 송금, 스왑, 수수료 대납, multisig 사용 |
| Scan / Explorer | 블록, 트랜잭션, 주소, 토큰, validator, mint/burn, swap 조회 |
| Admin Backoffice | 운영자용 권한, validator, stablecoin, fee, blacklist/freeze, mint/burn 관리 |

---

## 2. 프로젝트 개요

### 2.1 제품 비전

Private Cosmos 기반의 permissioned stablecoin network를 구축하여, 여러 법정화폐 기반 스테이블코인을 발행하고 안전하게 전송, 스왑, 관리할 수 있는 플랫폼을 제공한다.

### 2.2 핵심 목표

| 목표 | 설명 |
|---|---|
| 자체 private chain 구축 | Cosmos SDK와 CometBFT 기반 permissioned chain 구축 |
| 다중 스테이블코인 지원 | USD, GBP 등 여러 법정화폐 기반 stablecoin 추가 가능 |
| 권한 기반 발행/소각 | mint/burn은 권한 주소만 실행 가능 |
| validator 통제 | 50% 초과 합의 또는 super admin에 의한 validator 변경 가능 |
| 유연한 수수료 정책 | 각 stablecoin으로 fee 지불 가능, 특정 treasury 주소로 수수료 수취 |
| Fee delegation | 다른 주소가 사용자 gas fee를 대신 지불 가능 |
| Compliance 확장성 | 초기에는 blacklist-only 또는 bypass, 추후 KYC/AML 강제 가능 |
| Wallet/Scan/Admin 제공 | 실제 서비스 운영에 필요한 앱과 관리 도구 포함 |

---

## 3. 사용자 유형

| 사용자 | 설명 | 주요 기능 |
|---|---|---|
| 일반 사용자 | stablecoin 보유 및 전송 사용자 | 지갑 생성, 잔액 조회, 송금, 스왑 |
| 기관 사용자 | 기업/기관 계정 | multisig, fee delegation, 대량 송금, 승인 워크플로우 |
| Minter/Burner | 발행/소각 권한자 | stablecoin mint/burn 실행 |
| Validator Operator | validator node 운영자 | validator 상태 관리, 블록 생성 참여 |
| Super Admin | 긴급/최고 권한자 | validator 강제 추가/추방, 권한 변경, emergency pause |
| Compliance Admin | 주소 제한 관리 담당자 | blacklist, freeze, KYC/AML 상태 관리 |
| Fee Admin | 수수료 정책 관리자 | fee denom, fee rate, treasury 주소 설정 |
| Auditor | 감사자 | mint/burn, reserve, fee, admin action 조회 |

---

## 4. 제품 범위

### 4.1 In Scope

| 영역 | 포함 기능 |
|---|---|
| Chain | validator 관리, stablecoin, mint/burn, fee, swap, compliance, audit |
| Wallet | 계정 생성/복구, 잔액, 송금, fee 선택, swap, fee delegation, multisig |
| Scan | block, tx, address, token, validator, mint/burn, swap, fee 조회 |
| Admin | stablecoin, validator, role, fee, blacklist/freeze, mint/burn, swap 관리 |
| Indexer/API | chain data indexing, Wallet/Scan/Admin API 제공 |

### 4.2 Out of Scope for Initial MVP

| 항목 | 설명 |
|---|---|
| Public permissionless mainnet | 초기 버전은 private permissioned network |
| 완전한 KYC/AML 강제 | 초기에는 bypass 또는 blacklist-only |
| 외부 거래소 상장 | 별도 사업/규제 단계 |
| 모바일 앱 | MVP 이후 단계 |
| IBC 공개 연결 | 초기에는 선택 사항 또는 제외 |
| AMM 기반 DeFi | 초기 swap은 oracle/운영자 고시 환율 기반 우선 |

---

## 5. 핵심 요구사항

### 5.1 Validator 관리

- validator 추가/삭제는 active validator의 50% 초과 합의로 가능해야 한다.
- super admin은 validator를 강제 추가/추방할 수 있어야 한다.
- 모든 validator 변경은 온체인 이벤트와 audit log로 기록되어야 한다.

### 5.2 Super Admin

- super admin 권한은 단일 개인키가 아니라 multisig 주소에 부여하는 것을 기본으로 한다.
- super admin은 emergency pause, role 변경, validator 강제 변경이 가능해야 한다.

### 5.3 Fee Delegation

- 특정 주소가 다른 주소의 transaction fee를 대신 지불할 수 있어야 한다.
- spend limit, expiration, allowed message type을 설정할 수 있어야 한다.

### 5.4 Compliance

- 주소별 KYC, AML, whitelist, blacklist, freeze 상태를 관리할 수 있어야 한다.
- 초기 버전은 KYC/AML을 강제하지 않고 blacklist-only를 기본으로 한다.
- 추후 mode 변경만으로 KYC/AML required 정책으로 전환 가능해야 한다.

### 5.5 Multi-Stablecoin

- USD, GBP 등 stablecoin을 지속적으로 추가할 수 있어야 한다.
- denom별 issuer, minter, burner, fee policy, swap 가능 여부를 설정할 수 있어야 한다.

### 5.6 Swap

- stablecoin 간 swap이 가능해야 한다.
- pair별 환율과 수수료를 지정할 수 있어야 한다.
- 초기에는 oracle 또는 운영자 고시 환율 기반 swap을 우선한다.

### 5.7 Fee Policy

- 각 stablecoin을 fee token으로 사용할 수 있어야 한다.
- 수수료는 지정된 treasury 주소로 전송되어야 한다.
- tx fee, transfer fee, swap fee, mint/burn fee의 수취 주소를 분리할 수 있어야 한다.

### 5.8 Mint/Burn

- mint/burn은 특정 권한 주소만 실행할 수 있어야 한다.
- denom별 minter/burner를 별도로 설정할 수 있어야 한다.
- mint limit, pause, audit log를 지원해야 한다.

### 5.9 Multisig

- Cosmos SDK multisig 기반 기관용 multisig wallet을 지원해야 한다.
- mint, burn, treasury, super admin, validator admin 등 주요 권한은 multisig 사용을 권장한다.

---

## 6. Compliance 정책

초기 정책은 다음을 권장한다.

```text
mode = BLACKLIST_ONLY
kyc_required = false
aml_required = false
whitelist_required = false
blacklist_enabled = true
freeze_enabled = true
```

### Compliance Mode

| Mode | 설명 | 사용 시점 |
|---|---|---|
| BYPASS | 모든 주소 허용 | Devnet |
| BLACKLIST_ONLY | blacklist/frozen 주소만 차단 | MVP / Closed Pilot |
| WHITELIST_REQUIRED | whitelist 주소만 허용 | 제한 서비스 |
| KYC_AML_REQUIRED | KYC/AML 완료 주소만 허용 | 정식 규제 서비스 |

---

## 7. 성공 기준

| 기준 | 설명 |
|---|---|
| Chain 안정성 | private validator network가 안정적으로 block 생성 |
| 발행/소각 정확성 | 권한 주소만 mint/burn 가능 |
| 전송 정책 정확성 | compliance/fee 정책에 따라 tx 처리 |
| Wallet 사용성 | 사용자가 stablecoin 송금과 swap 가능 |
| Scan 투명성 | block, tx, token, validator, mint/burn 조회 가능 |
| Admin 운영성 | 운영자가 token, fee, validator, blacklist/freeze 관리 가능 |
| 감사 가능성 | 모든 중요 액션이 audit log로 추적 가능 |

