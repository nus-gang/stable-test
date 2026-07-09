# Private Cosmos Stablecoin Platform MVP Development Roadmap v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 단계별 MVP 개발 범위와 로드맵을 정의한다.

---

## 2. 개발 전략

초기에는 모든 기능을 한 번에 구현하지 않고 다음 순서로 진행한다.

```text
Phase 0: Discovery & Specification
Phase 1: Chain Foundation MVP
Phase 2: Wallet / Scan / Admin MVP
Phase 3: Swap / Fee Delegation / Multisig 확장
Phase 4: Reserve / Oracle / Advanced Compliance
Phase 5: Security Audit / Pilot Launch
```

---

# 3. Phase 0 — Discovery & Specification

## 목표

제품과 기술 요구사항을 확정하고 개발 착수 가능한 수준의 명세를 만든다.

## 주요 작업

| 작업 | 산출물 |
|---|---|
| 비즈니스 요구사항 정리 | PRD v1 |
| 기술 구조 설계 | Technical Architecture v1 |
| Chain module 설계 | Module Specification v1 |
| Wallet/Scan/Admin 화면 정의 | Screen Requirements v1 |
| MVP 범위 확정 | Roadmap v1 |
| 규제/라이선스 검토 | Legal/Compliance checklist |

## 완료 기준

- 핵심 요구사항 freeze
- MVP scope 확정
- chain module interface 초안 확정
- 개발 backlog 생성 가능

---

# 4. Phase 1 — Chain Foundation MVP

## 목표

Private Cosmos Chain의 기본 네트워크와 핵심 stablecoin 기능을 구현한다.

## 포함 기능

| 영역 | 기능 |
|---|---|
| Chain scaffold | Cosmos SDK app 생성 |
| Consensus | CometBFT 기반 private validator network |
| x/authority | 기본 role 관리 |
| x/stablecoin | stablecoin registry, mint, burn |
| x/compliance | BLACKLIST_ONLY mode, freeze/blacklist |
| x/feehandler | allowed fee denom, treasury address |
| x/audit | 핵심 이벤트 로그 |
| Basic CLI | stablecoin, compliance, authority tx/query |

## 제외 기능

| 기능 | 이유 |
|---|---|
| Swap | Phase 3에서 구현 |
| Advanced KYC/AML | 초기에는 bypass/blacklist-only |
| Reserve attestation | Phase 4 |
| Oracle | Phase 4 |
| Mobile wallet | MVP 이후 |

## 완료 기준

- 4개 이상 validator devnet 실행
- USDX stablecoin 생성 가능
- 권한 주소만 mint/burn 가능
- 일반 주소 간 stablecoin transfer 가능
- blacklist/frozen 주소 transfer 차단
- fee가 treasury 주소로 수취
- block/tx event 정상 발생

---

# 5. Phase 2 — Wallet / Scan / Admin MVP

## 목표

체인 기능을 실제 서비스로 사용할 수 있는 기본 UI와 API를 구현한다.

## 5.1 Indexer/API MVP

| 기능 | 설명 |
|---|---|
| Block indexing | block header 저장 |
| Tx indexing | tx hash/status/message 저장 |
| Event parsing | stablecoin, fee, compliance event 파싱 |
| Balance API | 주소별 balance 조회 |
| Token API | stablecoin registry 조회 |
| Tx history API | 주소별 거래 내역 |

## 5.2 Wallet MVP

| 기능 | 설명 |
|---|---|
| 지갑 생성/복구 | mnemonic 기반 |
| 잔액 조회 | stablecoin별 balance |
| 송금 | stablecoin transfer |
| Fee denom 선택 | 허용 stablecoin으로 fee 지불 |
| Tx history | 거래 내역 표시 |
| Compliance 상태 표시 | Transfer Enabled/Restricted |

## 5.3 Scan MVP

| 기능 | 설명 |
|---|---|
| Home dashboard | latest block, tx, validators |
| Block detail | block 정보 |
| Tx detail | tx/message/event 정보 |
| Address detail | balance, tx history |
| Token detail | supply, mint/burn history |
| Validator list | active validator 목록 |

## 5.4 Admin MVP

| 기능 | 설명 |
|---|---|
| Stablecoin 관리 | token 조회/수정 일부 |
| Mint/Burn | 권한 주소로 발행/소각 |
| Blacklist/Freeze | 주소 제한 관리 |
| Fee 설정 | fee denom/collector 설정 |
| Audit log | 중요 이벤트 조회 |

## 완료 기준

- 사용자가 web wallet에서 stablecoin 송금 가능
- scan에서 block/tx/address/token 조회 가능
- admin에서 mint/burn/blacklist/freeze 실행 가능
- indexer가 custom event 정상 파싱

---

# 6. Phase 3 — Swap / Fee Delegation / Multisig 확장

## 목표

서비스 핵심 차별 기능인 stablecoin swap, fee delegation, institutional multisig를 구현한다.

## 6.1 Chain 기능

| 모듈 | 기능 |
|---|---|
| x/stableswap | swap pair, rate, fee, swap execution |
| x/feehandler | fee type별 routing 고도화 |
| x/feegrant 또는 x/feedelegation | fee delegation policy |
| x/validatorauthority | validator vote 기반 추가/삭제 |
| x/authority | multisig admin address 지원 강화 |

## 6.2 Wallet 기능

| 기능 | 설명 |
|---|---|
| Swap 화면 | quote, fee, execution |
| Fee delegation 화면 | grant 조회, 사용 가능 한도 표시 |
| Multisig proposal | tx proposal 생성 |
| Multisig approval | signer 승인/거절 |
| Broadcast | threshold 충족 후 tx 전송 |

## 6.3 Scan/Admin 기능

| 제품 | 기능 |
|---|---|
| Scan | swap history, fee history, validator history |
| Admin | swap pair/rate/fee 관리 |
| Admin | validator proposal/vote/force action 관리 |
| Admin | role/multisig 관리 |

## 완료 기준

- USDX/GBPX swap 가능
- pair별 fee 적용 및 treasury 수취
- fee delegation으로 타 주소 수수료 대납 가능
- validator 추가/삭제 proposal/vote 실행 가능
- multisig로 mint 또는 admin tx 실행 가능

---

# 7. Phase 4 — Reserve / Oracle / Advanced Compliance

## 목표

정식 서비스와 감사 대응을 위한 준비금, 환율, compliance 기능을 강화한다.

## 포함 기능

| 영역 | 기능 |
|---|---|
| x/reserve | reserve report 제출/조회 |
| x/oracle | FX rate signer, rate submission |
| Compliance | WHITELIST_REQUIRED, KYC_AML_REQUIRED mode |
| Admin | KYC/AML status management |
| Scan | reserve dashboard |
| Wallet | KYC required 상태 안내 |
| Reporting | mint/burn/reserve/fee report export |

## 완료 기준

- reserve report 온체인 기록 가능
- swap rate를 oracle/admin signer가 제출 가능
- compliance mode를 운영자가 전환 가능
- KYC/AML required mode에서 미인증 주소 tx 차단
- reserve dashboard에서 supply/reserve ratio 조회 가능

---

# 8. Phase 5 — Security Audit / Pilot Launch

## 목표

보안 검증과 제한된 pilot 서비스를 준비한다.

## 주요 작업

| 영역 | 작업 |
|---|---|
| Chain audit | custom module 보안 리뷰 |
| Wallet audit | key management, tx signing 검토 |
| Admin audit | RBAC, MFA, audit log 검토 |
| Infra audit | validator key, node security, monitoring |
| Load test | tx throughput, indexer sync 성능 테스트 |
| Disaster recovery | node failure, chain halt recovery plan |
| Legal review | stablecoin, KYC/AML, 송금/결제 규제 검토 |
| Pilot onboarding | 제한된 기관 또는 내부 사용자 온보딩 |

## 완료 기준

- critical 보안 이슈 해결
- validator 장애 대응 절차 검증
- admin key/multisig 운영 절차 확정
- pilot launch checklist 완료

---

# 9. 권장 개발 순서 상세

## Sprint Group A — Chain Core

| 순서 | 작업 |
|---:|---|
| 1 | Cosmos SDK app scaffold |
| 2 | private validator devnet 구성 |
| 3 | x/authority 기본 구현 |
| 4 | x/stablecoin registry/mint/burn 구현 |
| 5 | x/compliance BLACKLIST_ONLY 구현 |
| 6 | x/feehandler 기본 구현 |
| 7 | event/audit 구현 |
| 8 | CLI/query 테스트 |

## Sprint Group B — Service Layer

| 순서 | 작업 |
|---:|---|
| 1 | indexer skeleton |
| 2 | block/tx/event parser |
| 3 | API gateway |
| 4 | Wallet MVP |
| 5 | Scan MVP |
| 6 | Admin MVP |

## Sprint Group C — Advanced Features

| 순서 | 작업 |
|---:|---|
| 1 | x/stableswap |
| 2 | swap UI/API |
| 3 | fee delegation |
| 4 | multisig workflow |
| 5 | validatorauthority voting |
| 6 | reserve/oracle |

---

# 10. 팀 구성 권장안

| 역할 | 인원 | 담당 |
|---|---:|---|
| Cosmos SDK Developer | 2 | chain, custom module |
| Backend/Indexer Developer | 1~2 | indexer, API, admin backend |
| Frontend Developer | 2 | wallet, scan, admin UI |
| DevOps/Infra Engineer | 1 | node, validator, monitoring, deployment |
| Security Engineer | 1 | key, multisig, audit, threat modeling |
| QA Engineer | 1 | chain/API/UI test |
| Product/Compliance | 1 | 요구사항, KYC/AML, 규제 검토 |

---

# 11. 주요 리스크와 대응

| 리스크 | 설명 | 대응 |
|---|---|---|
| Super admin 중앙화 | 강제 추방 권한 남용 가능 | multisig, audit, reason required |
| KYC/AML bypass | 정식 서비스 시 규제 리스크 | 초기 pilot 한정, mode 전환 가능 구조 |
| Fee multi-denom 복잡성 | Cosmos 기본 fee 구조와 충돌 가능 | custom antehandler/feehandler 설계 |
| Swap rate 신뢰성 | 환율 조작 가능 | oracle signer, audit log, rate validity |
| Mint 권한 탈취 | 무제한 발행 위험 | multisig, mint limit, pause, reserve check |
| Indexer 불일치 | chain data와 DB 불일치 | replay, reconciliation job |
| Private key 보안 | 운영키 유출 위험 | HSM/MPC/hardware wallet 고려 |

---

# 12. MVP 최종 정의

MVP의 최소 성공 상태는 다음과 같다.

```text
Private validator network 위에서 USDX 같은 stablecoin을 생성하고,
권한 주소가 mint/burn하며,
사용자가 wallet에서 송금하고,
scan에서 tx와 token supply를 조회하고,
admin이 blacklist/freeze와 fee 설정을 관리할 수 있는 상태.
```

MVP 이후 swap, fee delegation, multisig, reserve/oracle, advanced compliance를 단계적으로 확장한다.

