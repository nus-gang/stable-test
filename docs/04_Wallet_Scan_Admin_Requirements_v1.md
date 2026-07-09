# Wallet / Scan / Admin Screen Requirements v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 Wallet, Scan/Explorer, Admin Backoffice 화면 및 기능 요구사항을 정의한다.

---

# 2. Wallet Requirements

## 2.1 Wallet 유형

| Wallet 유형 | 대상 | 설명 |
|---|---|---|
| Web Wallet | 초기 사용자/기관 | MVP 우선 개발 대상 |
| Institutional Wallet | 기관/운영자 | multisig, 승인 워크플로우 중심 |
| Mobile Wallet | 일반 사용자 | MVP 이후 |
| Browser Extension | 고급 사용자 | MVP 이후 선택 |

---

## 2.2 Wallet 주요 화면

### 2.2.1 Onboarding 화면

| 기능 | 설명 |
|---|---|
| 새 지갑 생성 | mnemonic 생성 |
| 지갑 복구 | seed phrase/private key import |
| 보안 안내 | seed phrase 백업 안내 |
| 네트워크 선택 | private chain endpoint 선택 optional |

### 2.2.2 Dashboard 화면

| 항목 | 설명 |
|---|---|
| 총 자산 | stablecoin별 잔액 합산 표시 optional |
| 토큰 목록 | USDX, GBPX, EURX 등 표시 |
| 주소 | 현재 지갑 주소 및 copy 기능 |
| Compliance 상태 | Transfer Enabled / Restricted 등 단순 표시 |
| 최근 거래 | 최근 tx list |

### 2.2.3 Token Detail 화면

| 항목 | 설명 |
|---|---|
| Token balance | 해당 stablecoin 잔액 |
| Token info | denom, fiat currency, decimals |
| Fee 가능 여부 | fee token으로 사용 가능 여부 |
| Swap 가능 여부 | swap enabled 여부 |
| 거래 내역 | 해당 token tx history |

### 2.2.4 Send 화면

| 기능 | 설명 |
|---|---|
| 수신 주소 입력 | address validation 필요 |
| 토큰 선택 | stablecoin 선택 |
| 금액 입력 | balance 초과 방지 |
| Fee token 선택 | USDX/GBPX 등 허용 fee denom 선택 |
| Fee payer 선택 | 본인 또는 delegated sponsor |
| Compliance precheck | sender/receiver 전송 가능 여부 사전 확인 |
| Tx preview | amount, fee, total, receiver 표시 |
| 서명 및 전송 | tx sign/broadcast |

### 2.2.5 Receive 화면

| 기능 | 설명 |
|---|---|
| 주소 표시 | QR code 및 text |
| token별 안내 | 지원 stablecoin 목록 |
| compliance 안내 | 제한 주소의 경우 수신 불가 가능성 안내 |

### 2.2.6 Swap 화면

| 기능 | 설명 |
|---|---|
| From token 선택 | input stablecoin |
| To token 선택 | output stablecoin |
| Quote 조회 | rate, fee, expected output |
| Slippage 또는 rate validity | oracle/admin rate 유효 시간 표시 |
| Swap 실행 | tx sign/broadcast |
| Swap result | tx hash, input, output, fee |

### 2.2.7 Fee Delegation 화면

| 항목 | 설명 |
|---|---|
| 사용 가능한 grants | grantor, spend limit, expiration |
| 허용 tx type | 송금, swap 등 |
| 남은 한도 | remaining allowance |
| 만료일 | expiration |
| Grant 생성 optional | 기관 wallet에서 제공 |

### 2.2.8 Multisig 화면

| 기능 | 설명 |
|---|---|
| Multisig 계정 생성 | signer 목록, threshold 설정 |
| Proposal 생성 | tx proposal 생성 |
| Pending proposals | 승인 대기 목록 |
| Approve/Reject | signer별 승인/거절 |
| Signature collection | 서명 수집 상태 |
| Broadcast | threshold 충족 후 tx 전송 |
| History | multisig tx 이력 |

---

## 2.3 Wallet 비기능 요구사항

| 항목 | 요구사항 |
|---|---|
| Key security | private key는 client side에서 암호화 저장 |
| API 장애 대응 | RPC/API 장애 시 사용자에게 명확한 오류 표시 |
| Token registry | chain registry 조회로 신규 stablecoin 자동 반영 |
| Error message | compliance, fee 부족, blacklist 등 실패 사유 명확히 표시 |
| Audit support | 기관 wallet action log 제공 |

---

# 3. Scan / Explorer Requirements

## 3.1 Scan 주요 화면

### 3.1.1 Home Dashboard

| 항목 | 설명 |
|---|---|
| Latest block height | 최신 블록 높이 |
| Block time | 평균 block time |
| Total transactions | 누적 tx 수 |
| Active validators | 활성 validator 수 |
| Stablecoin supply | token별 supply 요약 |
| Recent transactions | 최근 tx 목록 |
| Recent blocks | 최근 block 목록 |

### 3.1.2 Block List / Detail

| 항목 | 설명 |
|---|---|
| Height | block height |
| Hash | block hash |
| Proposer | block proposer validator |
| Timestamp | 생성 시간 |
| Tx count | tx 개수 |
| Transactions | block 내 tx 목록 |

### 3.1.3 Transaction Detail

| 항목 | 설명 |
|---|---|
| Tx hash | transaction hash |
| Status | success/fail |
| Height | 포함 block height |
| Messages | msg type별 상세 |
| Fee | fee denom/amount/payer |
| Events | decoded events |
| Signer | signer address |
| Error log | 실패 시 reason |

### 3.1.4 Address Detail

| 항목 | 설명 |
|---|---|
| Address | 지갑 주소 |
| Balances | stablecoin별 잔액 |
| Tx history | 주소 관련 tx 목록 |
| Token transfers | token별 transfer |
| Compliance status | 공개 정책에 따라 제한 표시 |

주의: KYC/AML 상세 정보는 공개 scan에 표시하지 않는다.

### 3.1.5 Token List / Detail

| 항목 | 설명 |
|---|---|
| Display denom | USDX, GBPX 등 |
| Base denom | uusdx, ugbpx 등 |
| Fiat currency | USD, GBP 등 |
| Total supply | 총 발행량 |
| Max supply | 최대 발행량 |
| Issuer | issuer address |
| Mint/Burn history | 발행/소각 내역 |
| Swap enabled | swap 가능 여부 |
| Fee enabled | fee token 가능 여부 |

### 3.1.6 Validator 화면

| 항목 | 설명 |
|---|---|
| Active validators | active set 목록 |
| Voting power | voting power |
| Status | active/inactive/removed |
| Change history | 추가/삭제/강제추방 이력 |
| Proposal history | validator change proposal |

### 3.1.7 Mint/Burn 화면

| 항목 | 설명 |
|---|---|
| Denom | 대상 stablecoin |
| Type | mint 또는 burn |
| Amount | 수량 |
| Actor | 실행 주소 |
| Recipient | 대상 주소 |
| Tx hash | transaction |
| Timestamp | 시간 |

### 3.1.8 Swap 화면

| 항목 | 설명 |
|---|---|
| Pair | USDX/GBPX 등 |
| Input amount | 입력 수량 |
| Output amount | 출력 수량 |
| Rate | 적용 환율 |
| Fee | swap fee |
| User | 실행 주소 |
| Tx hash | transaction |

### 3.1.9 Fee Dashboard

| 항목 | 설명 |
|---|---|
| Fee denom | 수수료 denom |
| Fee amount | 수수료 수량 |
| Fee type | tx/transfer/swap/mint/burn |
| Collector | 수취 주소 |
| Time | 수취 시간 |

---

## 3.2 Scan 공개 정책

| 데이터 | 공개 범위 추천 |
|---|---|
| block/tx hash | 공개 가능 |
| token supply | 공개 가능 |
| mint/burn 총량 | 공개 또는 제한 공개 |
| address balance | 정책에 따라 제한 |
| KYC/AML 상태 | 비공개 |
| blacklist/freeze 상세 | 관리자 전용 |
| super admin action | 감사 목적상 공개 또는 기관 전용 |

---

# 4. Admin Backoffice Requirements

## 4.1 Admin 사용자 역할

| 역할 | 설명 |
|---|---|
| Super Admin | 전체 시스템 최고 권한 |
| Chain Admin | chain 설정 및 validator 관리 |
| Stablecoin Admin | token 생성/수정, mint/burn 관리 |
| Compliance Admin | blacklist/freeze/KYC/AML 관리 |
| Fee Admin | fee policy 관리 |
| Swap Admin | pair/rate/fee 관리 |
| Auditor | read-only 감사 권한 |

---

## 4.2 Admin 주요 화면

### 4.2.1 Admin Dashboard

| 항목 | 설명 |
|---|---|
| Chain status | block height, validator status |
| Stablecoin supply | token별 supply |
| Pending actions | 승인 대기 mint/burn/multisig tx |
| Alerts | node down, failed tx, abnormal activity |
| Recent admin actions | 최근 운영자 액션 |

### 4.2.2 Stablecoin Management

| 기능 | 설명 |
|---|---|
| Stablecoin 등록 | denom, display, fiat currency, decimals 설정 |
| Stablecoin 수정 | issuer, max supply, fee config 수정 |
| Pause/Resume | token 기능 중지/재개 |
| Minter/Burner 설정 | denom별 권한 주소 설정 |
| Mint limit 설정 | 1회/일일 한도 설정 |

### 4.2.3 Mint/Burn Management

| 기능 | 설명 |
|---|---|
| Mint 요청 생성 | denom, amount, recipient 입력 |
| Burn 요청 생성 | denom, amount, source 입력 |
| Approval workflow | multisig 또는 admin approval |
| 실행 결과 조회 | tx hash/status 확인 |
| 내역 조회 | 기간/denom/address별 필터 |

### 4.2.4 Compliance Management

| 기능 | 설명 |
|---|---|
| Compliance mode 변경 | BYPASS, BLACKLIST_ONLY 등 |
| Address 검색 | 주소별 상태 조회 |
| Blacklist 추가/해제 | 위험 주소 차단/해제 |
| Freeze/Unfreeze | 주소 동결/해제 |
| KYC/AML 상태 설정 | 추후 정식 서비스용 |
| 변경 사유 입력 | audit를 위한 reason 기록 |

초기 MVP 기본값:

```text
mode = BLACKLIST_ONLY
kyc_required = false
aml_required = false
whitelist_required = false
blacklist_enabled = true
freeze_enabled = true
```

### 4.2.5 Fee Management

| 기능 | 설명 |
|---|---|
| Allowed fee denom 설정 | fee로 사용할 stablecoin 관리 |
| Min gas price 설정 | denom별 gas price |
| Treasury 주소 설정 | 수수료 수취 주소 |
| Fee type별 routing | tx/swap/mint/burn fee 분리 |
| Fee history 조회 | 수수료 수취 내역 |

### 4.2.6 Swap Management

| 기능 | 설명 |
|---|---|
| Swap pair 생성 | USDX/GBPX 등 |
| Exchange rate 설정 | pair별 환율 |
| Swap fee 설정 | pair별 수수료율 |
| Pair pause/resume | swap 중지/재개 |
| Swap history 조회 | pair/user/time별 조회 |

### 4.2.7 Validator Management

| 기능 | 설명 |
|---|---|
| Validator 목록 | active/inactive 상태 조회 |
| 후보 등록 | 신규 validator 후보 등록 |
| Add/Remove proposal | 추가/삭제 제안 생성 |
| Vote | validator 변경 투표 |
| Force Add/Remove | super admin 강제 추가/추방 |
| Change history | 변경 이력 조회 |

### 4.2.8 Authority / Role Management

| 기능 | 설명 |
|---|---|
| Role 목록 | 시스템 role 목록 조회 |
| 주소별 권한 조회 | 특정 주소 role 확인 |
| Role 부여/회수 | grant/revoke role |
| Multisig 권한 설정 | multisig 주소를 admin으로 지정 |
| 권한 변경 이력 | audit log 조회 |

### 4.2.9 Audit Log

| 기능 | 설명 |
|---|---|
| 이벤트 검색 | actor/action/time 기준 검색 |
| 상세 조회 | tx hash, actor, reason, payload |
| Export | CSV/PDF optional |
| 위험 액션 필터 | super admin, mint/burn, freeze 등 |

---

## 4.3 Admin 보안 요구사항

| 항목 | 요구사항 |
|---|---|
| Authentication | 관리자 로그인, MFA 권장 |
| Authorization | role-based access control |
| Tx signing | 중요 tx는 multisig 또는 hardware signer 권장 |
| Audit | 모든 관리자 액션 기록 |
| Reason required | blacklist, force remove 등 중요 액션은 사유 필수 |
| Session control | session timeout, IP allowlist optional |

