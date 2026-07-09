# Private Cosmos Stablecoin Platform Genesis Policy v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 **초기 체인 생성, genesis 설정, 운영 권한, 초기 토큰 정책, validator 정책**을 정의한다.

이 문서는 개발팀이 Cosmos SDK chain scaffold 및 devnet을 구성할 때 기준으로 사용할 수 있는 **개발 착수용 정책 문서**이다.

---

## 2. Genesis Policy 요약

| 항목 | 초기 정책 |
|---|---|
| Chain ID | `stablecoin-private-1` |
| Chain Type | Private permissioned Cosmos SDK chain |
| Consensus | CometBFT |
| Initial Validator Count | 4 |
| Initial Stablecoin | USDX |
| Base Denom | `uusdx` |
| Display Denom | `USDX` |
| Decimals | 6 |
| Initial Supply | 0 |
| Initial Compliance Mode | `BLACKLIST_ONLY` |
| Initial Fee Denom | `uusdx` |
| Fee Collector | Treasury address |
| Initial KYC/AML | Not required |
| Initial Whitelist | Not required |
| Blacklist | Enabled |
| Freeze | Enabled |
| Mint/Burn | Role-based only |
| Admin Model | Role-based authority, multisig-ready |

---

## 3. Chain 기본 설정

## 3.1 Chain Identity

| 항목 | 값 |
|---|---|
| Chain ID | `stablecoin-private-1` |
| Chain Name | `Stablecoin Private Chain` |
| Network Type | Private / Permissioned |
| Environment | Local Devnet → Internal Testnet → Closed Pilot |
| Native Business Asset | USDX stablecoin |

## 3.2 Address Prefix

초기 주소 prefix는 프로젝트 브랜드 확정 전까지 임시값을 사용한다.

| 항목 | 제안값 |
|---|---|
| Account address prefix | `stbc` |
| Validator operator prefix | `stbcvaloper` |
| Consensus node prefix | `stbcvalcons` |
| Pubkey prefix | `stbcpub` |

> 브랜드명이 확정되면 prefix는 mainnet 전에 변경할 수 있다. 단, 한 번 운영 환경에 들어가면 prefix 변경은 migration 부담이 있으므로 초기에 확정하는 것이 좋다.

---

## 4. Environment별 Genesis 정책

## 4.1 Local Devnet

| 항목 | 정책 |
|---|---|
| 목적 | 개발자 로컬 테스트 |
| Validator 수 | 1 또는 4 |
| Key 보안 | 개발용 mnemonic 허용 |
| Compliance mode | `BYPASS` 또는 `BLACKLIST_ONLY` |
| Initial token | USDX |
| Faucet | 허용 가능 |
| Admin key | 개발용 단일 키 허용 |
| 데이터 보존 | 재생성 가능 |

## 4.2 Internal Testnet

| 항목 | 정책 |
|---|---|
| 목적 | 내부 통합 테스트 |
| Validator 수 | 4 |
| Key 보안 | 팀별 validator key 분리 |
| Compliance mode | `BLACKLIST_ONLY` |
| Initial token | USDX |
| Faucet | 제한적 허용 |
| Admin key | 최소 2-of-3 또는 운영자 분리 권장 |
| 데이터 보존 | 테스트 기간 동안 보존 |

## 4.3 Closed Pilot

| 항목 | 정책 |
|---|---|
| 목적 | 제한된 기관/사용자 파일럿 |
| Validator 수 | 4 이상 |
| Key 보안 | validator key 분리, hardware signer 검토 |
| Compliance mode | `BLACKLIST_ONLY` 또는 `WHITELIST_REQUIRED` |
| Initial token | USDX, 필요 시 GBPX 추가 가능 |
| Faucet | 비활성화 권장 |
| Admin key | multisig 권장 |
| 데이터 보존 | 감사 목적으로 보존 |

---

## 5. Initial Stablecoin Policy

## 5.1 USDX Genesis Definition

| 항목 | 값 |
|---|---|
| Display Denom | `USDX` |
| Base Denom | `uusdx` |
| Fiat Currency | USD |
| Decimals | 6 |
| Initial Supply | 0 |
| Mintable | Yes |
| Burnable | Yes |
| Transferable | Yes, unless compliance blocks |
| Paused at Genesis | No |
| Swap Enabled | No for MVP |
| Fee Enabled | Yes |

## 5.2 Amount Convention

USDX는 6 decimals를 사용한다.

| Display Amount | Base Amount |
|---:|---:|
| 1 USDX | 1,000,000 `uusdx` |
| 10 USDX | 10,000,000 `uusdx` |
| 100 USDX | 100,000,000 `uusdx` |
| 1,000 USDX | 1,000,000,000 `uusdx` |

## 5.3 Initial Supply 정책

MVP genesis에서는 initial supply를 0으로 설정한다.

```text
initial_supply = 0 uusdx
```

이유:

- 발행은 반드시 권한 있는 minter action으로 기록되도록 한다.
- genesis allocation으로 stablecoin을 임의 배포하지 않는다.
- 발행 이력과 supply 증가를 audit 가능하게 만든다.

## 5.4 Initial Mint 정책

MVP 데모 또는 테스트를 위한 최초 발행은 genesis 이후 `MsgMintStablecoin`으로 수행한다.

예시:

```text
Minter -> User A: mint 1,000 USDX
Amount: 1,000,000,000 uusdx
Reason: MVP initial test mint
```

---

## 6. Admin Role Genesis Policy

## 6.1 초기 Role 목록

| Role | 설명 | Genesis 포함 여부 |
|---|---|---:|
| `SUPER_ADMIN` | 최고 권한 | 포함 |
| `STABLECOIN_ADMIN` | stablecoin 관리 | 포함 |
| `MINTER` | 발행 권한 | 포함 |
| `BURNER` | 소각 권한 | 포함 |
| `COMPLIANCE_ADMIN` | blacklist/freeze 관리 | 포함 |
| `FEE_ADMIN` | fee 정책 관리 | 포함 |
| `VALIDATOR_ADMIN` | validator 정책 관리 | 선택 |
| `AUDITOR` | 감사 조회 권한 | 선택 |

## 6.2 개발 환경 Role Address 정책

Local Devnet에서는 개발 편의를 위해 하나의 개발 admin 주소가 여러 role을 가질 수 있다.

```text
DEV_ADMIN:
- SUPER_ADMIN
- STABLECOIN_ADMIN
- MINTER
- BURNER
- COMPLIANCE_ADMIN
- FEE_ADMIN
```

단, Internal Testnet부터는 role을 분리한다.

## 6.3 Testnet/Pilot Role 분리 권장

| Role | 권장 주소 유형 |
|---|---|
| `SUPER_ADMIN` | multisig address |
| `STABLECOIN_ADMIN` | multisig 또는 운영자 주소 |
| `MINTER` | mint 전용 운영 주소 또는 multisig |
| `BURNER` | burn 전용 운영 주소 또는 multisig |
| `COMPLIANCE_ADMIN` | compliance 운영 주소 |
| `FEE_ADMIN` | finance/treasury 운영 주소 |
| `AUDITOR` | read-only 감사 주소 |

## 6.4 Super Admin 정책

Super Admin은 다음 권한을 가진다.

| 권한 | MVP 포함 여부 |
|---|---:|
| Role grant/revoke | 포함 |
| Stablecoin emergency pause | 포함 |
| Compliance emergency action | 포함 |
| Fee collector emergency update | 포함 |
| Validator force add/remove | MVP에서는 optional/stub |

Super Admin은 운영 환경에서 반드시 multisig로 전환해야 한다.

---

## 7. Genesis Account Policy

## 7.1 필수 Genesis Accounts

| 계정 | 용도 | 초기 잔액 정책 |
|---|---|---|
| `DEV_ADMIN` | 개발/초기 admin | devnet에서만 사용 |
| `SUPER_ADMIN` | 최고 권한 | 운영 전 multisig 권장 |
| `MINTER` | USDX 발행 | gas용 소량 token 필요 |
| `BURNER` | USDX 소각 | gas용 소량 token 필요 |
| `COMPLIANCE_ADMIN` | blacklist/freeze | gas용 소량 token 필요 |
| `FEE_ADMIN` | fee 설정 | gas용 소량 token 필요 |
| `TREASURY` | 수수료 수취 | 수수료 누적 |
| `USER_A` | 테스트 사용자 | genesis allocation 없음, mint로 지급 |
| `USER_B` | 테스트 사용자 | genesis allocation 없음, mint로 지급 |

## 7.2 Genesis Allocation 원칙

MVP에서는 stablecoin의 genesis allocation을 최소화한다.

| 계정 유형 | Genesis USDX Allocation |
|---|---:|
| Admin 계정 | 0 또는 gas 테스트용 최소량 |
| Treasury | 0 |
| User 계정 | 0 |
| Validator 계정 | consensus/staking 목적 토큰이 별도일 경우만 allocation |

> 만약 gas token으로 `uusdx`를 사용한다면 초기 admin tx 실행을 위해 개발 환경에서는 admin 계정에 최소량의 `uusdx`를 genesis allocation할 수 있다. 다만 stablecoin supply audit 관점에서는 genesis allocation보다 mint tx를 통한 지급을 권장한다.

---

## 8. Validator Genesis Policy

## 8.1 Initial Validator Set

초기 devnet validator는 4개를 기준으로 한다.

| Validator | 용도 | Voting Power 제안 |
|---|---|---:|
| `validator-1` | primary project validator | 1 |
| `validator-2` | secondary project validator | 1 |
| `validator-3` | partner/auditor simulation | 1 |
| `validator-4` | technical operator simulation | 1 |

## 8.2 Validator 변경 정책

MVP에서 validator set 변경은 다음 단계로 나눈다.

| 단계 | 정책 |
|---|---|
| MVP | genesis 또는 운영자 수동 설정 중심 |
| Phase 3 | active validator 50% 초과 투표로 추가/삭제 |
| Phase 3+ | Super Admin force add/remove |

## 8.3 Validator 운영 정책

| 항목 | 정책 |
|---|---|
| Validator keys | node별 분리 |
| Consensus key | validator별 별도 관리 |
| Node monitoring | Prometheus/Grafana 대상 |
| Slashing | MVP에서는 단순화 가능 |
| Staking economics | private chain이므로 MVP에서는 생략 또는 최소화 |

---

## 9. Compliance Genesis Policy

## 9.1 Initial Compliance Mode

MVP 기본 compliance mode는 `BLACKLIST_ONLY`로 설정한다.

```text
compliance_mode = BLACKLIST_ONLY
kyc_required = false
aml_required = false
whitelist_required = false
blacklist_enabled = true
freeze_enabled = true
```

## 9.2 Mode별 의미

| Mode | 설명 | Genesis 사용 여부 |
|---|---|---:|
| `BYPASS` | 모든 주소 허용 | local devnet 가능 |
| `BLACKLIST_ONLY` | blacklist/frozen 주소만 차단 | MVP 기본 |
| `WHITELIST_REQUIRED` | whitelist 주소만 허용 | pilot 이후 |
| `KYC_AML_REQUIRED` | KYC/AML 완료 주소만 허용 | 정식 규제 서비스 |

## 9.3 Initial Blacklist/Freeze

MVP genesis에서는 blacklist와 frozen list를 비워둔다.

```text
blacklisted_addresses = []
frozen_addresses = []
```

테스트 시 Admin 또는 CLI를 통해 사용자 B를 blacklist 처리하여 transfer restriction을 검증한다.

## 9.4 On-chain 개인정보 정책

Genesis 및 on-chain state에는 개인정보를 저장하지 않는다.

| 저장 금지 | 설명 |
|---|---|
| 실명 | 온체인 저장 금지 |
| 신분증 번호 | 온체인 저장 금지 |
| 주소/전화번호 | 온체인 저장 금지 |
| AML 상세 결과 | 온체인 저장 금지 |
| KYC 문서 | 온체인 저장 금지 |

온체인에는 필요한 경우 상태값 또는 offchain reference hash만 저장한다.

---

## 10. Fee Genesis Policy

## 10.1 Initial Fee Denom

MVP에서는 `uusdx`를 transaction fee denom으로 허용한다.

| 항목 | 값 |
|---|---|
| Allowed Fee Denom | `uusdx` |
| Fee Display | USDX |
| Fee Decimals | 6 |
| Fee Collector | `TREASURY` address |

## 10.2 Min Gas Price 제안

초기 devnet에서는 테스트 편의를 위해 낮은 값을 사용한다.

| Environment | Min Gas Price 제안 |
|---|---:|
| Local Devnet | `0.000001uusdx` |
| Internal Testnet | `0.00001uusdx` |
| Closed Pilot | 운영 정책에 따라 조정 |

## 10.3 Fee Routing

MVP fee routing은 단순화한다.

```text
Transaction Fee -> fee_collector module account -> TREASURY
```

또는 구현 단순화를 위해 다음 구조도 허용한다.

```text
Transaction Fee -> TREASURY
```

단, 추후 fee type별 분배를 위해 `x/feehandler`에서 fee event를 반드시 발생시킨다.

## 10.4 Fee Type 확장 예정

| Fee Type | MVP | Phase |
|---|---:|---|
| Transaction fee | 포함 | MVP |
| Transfer fee | 선택 | Phase 2 |
| Swap fee | 제외 | Phase 3 |
| Mint fee | 제외 | Phase 3+ |
| Burn/Redeem fee | 제외 | Phase 3+ |

---

## 11. Stablecoin Registry Genesis Policy

## 11.1 Initial Registry Entry

Genesis 또는 초기 admin tx를 통해 USDX를 등록한다.

| 필드 | 값 |
|---|---|
| denom | `uusdx` |
| display_name | `USDX` |
| fiat_currency | `USD` |
| decimals | 6 |
| issuer | project issuer address |
| max_supply | MVP에서는 optional 또는 충분히 큰 값 |
| paused | false |
| mint_roles | `MINTER` |
| burn_roles | `BURNER` |
| fee_enabled | true |
| swap_enabled | false |

## 11.2 Max Supply 정책

MVP에서는 다음 중 하나를 선택한다.

| 옵션 | 설명 | 추천 |
|---|---|---:|
| No max supply | 발행 한도 없음, 권한으로만 제한 | 개발 편의 높음 |
| Large max supply | 예: 1,000,000,000 USDX | 추천 |
| Reserve-based limit | reserve module과 연동 | Phase 4 |

MVP 추천:

```text
max_supply = 1,000,000,000 USDX
base_amount = 1,000,000,000,000,000 uusdx
```

---

## 12. Audit Genesis Policy

## 12.1 Audit Event 활성화

MVP genesis부터 audit event를 활성화한다.

| 이벤트 | MVP 기록 여부 |
|---|---:|
| role grant/revoke | 포함 |
| stablecoin create/update | 포함 |
| mint/burn | 포함 |
| pause/resume | 포함 |
| blacklist/freeze | 포함 |
| fee config update | 포함 |
| validator change | optional |

## 12.2 Audit Log 저장 위치

| 위치 | 설명 |
|---|---|
| On-chain event | 필수 |
| `x/audit` state | 선택, 검색 최적화 필요 시 |
| Indexer DB | 필수, Admin/Scan 조회용 |

MVP에서는 on-chain event + indexer DB 저장을 우선한다.

---

## 13. Governance Genesis Policy

MVP에서는 일반 public governance를 사용하지 않는다.

| 항목 | 정책 |
|---|---|
| Public governance | 비활성 또는 제한 |
| Parameter change | admin role 기반 |
| Validator change | MVP에서는 수동/운영자 관리, Phase 3에서 투표 모듈 |
| Emergency action | Super Admin 기반 |

이유:

- private chain에서는 validator/operator 중심 권한 관리가 더 적합하다.
- 초기 제품 검증 단계에서는 복잡한 governance보다 admin authority가 구현과 운영이 단순하다.

---

## 14. Genesis File 구성 예시

아래는 실제 genesis 구조를 설계할 때 참고할 conceptual 예시이다.

```json
{
  "chain_id": "stablecoin-private-1",
  "app_state": {
    "authority": {
      "roles": [
        {
          "address": "<super_admin_address>",
          "roles": ["SUPER_ADMIN"]
        },
        {
          "address": "<minter_address>",
          "roles": ["MINTER"]
        },
        {
          "address": "<burner_address>",
          "roles": ["BURNER"]
        },
        {
          "address": "<compliance_admin_address>",
          "roles": ["COMPLIANCE_ADMIN"]
        },
        {
          "address": "<fee_admin_address>",
          "roles": ["FEE_ADMIN"]
        }
      ]
    },
    "stablecoin": {
      "stablecoins": [
        {
          "denom": "uusdx",
          "display_name": "USDX",
          "fiat_currency": "USD",
          "decimals": 6,
          "initial_supply": "0",
          "max_supply": "1000000000000000",
          "paused": false,
          "fee_enabled": true,
          "swap_enabled": false
        }
      ]
    },
    "compliance": {
      "mode": "BLACKLIST_ONLY",
      "kyc_required": false,
      "aml_required": false,
      "whitelist_required": false,
      "blacklisted_addresses": [],
      "frozen_addresses": []
    },
    "feehandler": {
      "allowed_fee_denoms": ["uusdx"],
      "fee_collector": "<treasury_address>",
      "min_gas_prices": [
        {
          "denom": "uusdx",
          "amount": "0.000001"
        }
      ]
    }
  }
}
```

> 실제 Cosmos SDK genesis format은 구현 모듈의 protobuf/state 구조에 따라 달라진다. 위 예시는 정책 구조를 보여주기 위한 conceptual template이다.

---

## 15. Genesis 이후 초기화 절차

MVP devnet 구동 후 다음 순서로 초기 검증을 수행한다.

| 순서 | 작업 | 검증 |
|---:|---|---|
| 1 | 4-validator devnet 시작 | block 생성 확인 |
| 2 | chain ID 확인 | `stablecoin-private-1` |
| 3 | role query | admin/minter/burner role 확인 |
| 4 | stablecoin query | USDX registry 확인 |
| 5 | fee config query | `uusdx` fee denom 확인 |
| 6 | compliance config query | `BLACKLIST_ONLY` 확인 |
| 7 | mint 1,000 USDX to User A | User A balance 증가 |
| 8 | User A → User B 100 USDX transfer | tx success |
| 9 | blacklist User B | compliance state 변경 |
| 10 | User B transfer attempt | tx fail |
| 11 | scan/indexer 확인 | tx/event/history 저장 확인 |

---

## 16. 개발 착수 확정값

개발팀은 우선 아래 값을 기본값으로 사용한다.

| 항목 | 값 | 상태 |
|---|---|---|
| Chain ID | `stablecoin-private-1` | 확정 제안 |
| Address Prefix | `stbc` | 임시 확정 제안 |
| Initial Validators | 4 | 확정 제안 |
| Initial Stablecoin | USDX | 확정 제안 |
| Base Denom | `uusdx` | 확정 제안 |
| Decimals | 6 | 확정 제안 |
| Initial Supply | 0 | 확정 제안 |
| Compliance Mode | `BLACKLIST_ONLY` | 확정 제안 |
| Fee Denom | `uusdx` | 확정 제안 |
| Fee Collector | `TREASURY` | 주소 생성 필요 |
| Admin Model | Role-based | 확정 제안 |
| Multisig | 운영 환경 필수 권장 | MVP UI는 제외 |

---

## 17. Open Decisions

개발 착수 전 또는 Phase 1 중 확정해야 할 항목이다.

| 항목 | 선택지 | 권장 |
|---|---|---|
| Cosmos SDK version | 최신 stable version | 착수 시 lock |
| Go version | SDK 호환 버전 | 착수 시 lock |
| Address prefix | `stbc` 또는 브랜드명 | 브랜드 확정 필요 |
| Gas token 구조 | `uusdx` only 또는 별도 staking token | MVP는 `uusdx` only |
| Staking module 사용 여부 | 사용/미사용 | private chain이면 최소화 가능 |
| Genesis stablecoin 등록 방식 | genesis 포함 또는 admin tx | genesis 포함 권장 |
| Fee collector routing | direct treasury 또는 module account 경유 | module account 경유 권장 |
| Super Admin address | dev key 또는 multisig | devnet은 key, pilot은 multisig |

---

## 18. Genesis Policy 완료 기준

Genesis Policy는 다음 조건을 만족하면 개발 착수 기준으로 충분하다.

| 기준 | 상태 |
|---|---|
| Chain ID 정의 | 완료 |
| Initial stablecoin 정의 | 완료 |
| Initial compliance mode 정의 | 완료 |
| Initial fee denom 정의 | 완료 |
| Admin roles 정의 | 완료 |
| Validator count 정의 | 완료 |
| Genesis account 정책 정의 | 완료 |
| Initial audit 대상 정의 | 완료 |
| Genesis 이후 검증 절차 정의 | 완료 |

---

## 19. 최종 요약

MVP Genesis의 핵심은 다음과 같다.

```text
Chain ID: stablecoin-private-1
Initial Token: USDX / uusdx / 6 decimals
Initial Supply: 0
Validators: 4
Compliance: BLACKLIST_ONLY
Fee Denom: uusdx
Fee Collector: TREASURY
Mint/Burn: role-based only
Admin: role-based, multisig-ready
```

이 정책을 기준으로 Phase 1에서는 Cosmos SDK chain scaffold, 4-validator devnet, `x/authority`, `x/stablecoin`, `x/compliance`, `x/feehandler`, `x/audit` 구현을 시작한다.
