# Private Cosmos Stablecoin Chain Module Specification v1

## 1. 문서 목적

본 문서는 Private Cosmos Stablecoin Platform의 chain layer에서 필요한 custom module의 기능 명세를 정의한다.

---

## 2. Module Overview

| 모듈 | 목적 |
|---|---|
| x/authority | 역할과 권한 관리 |
| x/validatorauthority | validator 추가/삭제/강제추방 |
| x/compliance | KYC/AML, whitelist, blacklist, freeze 정책 |
| x/stablecoin | 다중 stablecoin registry, mint, burn, pause |
| x/stableswap | stablecoin 간 swap, rate, fee |
| x/feehandler | multi fee denom, fee collection, treasury routing |
| x/reserve | reserve attestation, supply-reserve 검증 |
| x/oracle | FX rate 또는 운영자 고시 환율 |
| x/audit | 중요 액션 감사 로그 |

---

# 3. x/authority

## 3.1 목적

체인 내 모든 권한 주소와 역할을 관리한다.

## 3.2 Roles

| Role | 설명 |
|---|---|
| SUPER_ADMIN | 최고 권한, 강제 validator 변경 및 emergency action 가능 |
| VALIDATOR_ADMIN | validator 관리 권한 |
| STABLECOIN_ADMIN | stablecoin 생성/수정 권한 |
| MINTER | 특정 denom mint 권한 |
| BURNER | 특정 denom burn 권한 |
| COMPLIANCE_ADMIN | blacklist/freeze/KYC 상태 변경 권한 |
| FEE_ADMIN | fee policy 변경 권한 |
| SWAP_ADMIN | swap pair/rate/fee 변경 권한 |
| RESERVE_REPORTER | reserve report 제출 권한 |
| AUDITOR | 감사 데이터 조회 권한 |

## 3.3 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgGrantRole | 주소에 role 부여 | SUPER_ADMIN |
| MsgRevokeRole | 주소에서 role 회수 | SUPER_ADMIN |
| MsgUpdateRoleAdmin | role 관리자 변경 | SUPER_ADMIN |
| MsgEmergencyPause | 주요 기능 일시 중지 | SUPER_ADMIN |
| MsgEmergencyUnpause | pause 해제 | SUPER_ADMIN |

## 3.4 Queries

| Query | 설명 |
|---|---|
| QueryHasRole | 특정 주소가 role을 갖는지 확인 |
| QueryRolesByAddress | 주소별 role 목록 조회 |
| QueryAddressesByRole | role별 주소 목록 조회 |
| QueryAuthorityParams | authority parameter 조회 |

## 3.5 Events

- authority.role_granted
- authority.role_revoked
- authority.emergency_paused
- authority.emergency_unpaused

---

# 4. x/validatorauthority

## 4.1 목적

Permissioned validator set을 관리한다.

## 4.2 기능

- validator 후보 등록
- validator 추가 제안
- validator 삭제 제안
- active validator의 50% 초과 투표에 따른 변경 실행
- super admin 강제 추가/추방
- validator 변경 이력 저장

## 4.3 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgRegisterValidatorCandidate | 후보 등록 | VALIDATOR_ADMIN 또는 후보 |
| MsgProposeAddValidator | validator 추가 제안 | active validator |
| MsgProposeRemoveValidator | validator 삭제 제안 | active validator |
| MsgVoteValidatorChange | 추가/삭제 제안에 투표 | active validator |
| MsgExecuteValidatorChange | 승인된 변경 실행 | anyone 또는 module |
| MsgForceAddValidator | 강제 validator 추가 | SUPER_ADMIN |
| MsgForceRemoveValidator | 강제 validator 추방 | SUPER_ADMIN |

## 4.4 Approval Rule

```text
approval_ratio > 50% of active validators
```

## 4.5 Queries

| Query | 설명 |
|---|---|
| QueryValidatorCandidates | 후보 목록 |
| QueryValidatorChangeProposal | 변경 제안 상세 |
| QueryValidatorChangeProposals | 변경 제안 목록 |
| QueryValidatorHistory | 변경 이력 |

## 4.6 Events

- validator.candidate_registered
- validator.add_proposed
- validator.remove_proposed
- validator.change_voted
- validator.added
- validator.removed
- validator.force_added
- validator.force_removed

---

# 5. x/compliance

## 5.1 목적

주소별 compliance 상태와 전송 가능 여부를 관리한다.

## 5.2 Compliance Modes

| Mode | 설명 |
|---|---|
| BYPASS | 모든 주소 허용 |
| BLACKLIST_ONLY | blacklist/frozen 주소만 차단 |
| WHITELIST_REQUIRED | whitelist 주소만 허용 |
| KYC_AML_REQUIRED | KYC/AML 완료 주소만 허용 |

## 5.3 Address Status

| 상태 | 설명 |
|---|---|
| KYC_VERIFIED | KYC 완료 |
| AML_CLEARED | AML 완료 |
| WHITELISTED | whitelist 등록 |
| BLACKLISTED | 거래 차단 |
| FROZEN | 자산 동결 |

## 5.4 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgSetComplianceMode | compliance mode 변경 | COMPLIANCE_ADMIN |
| MsgSetKycStatus | KYC 상태 설정 | COMPLIANCE_ADMIN |
| MsgSetAmlStatus | AML 상태 설정 | COMPLIANCE_ADMIN |
| MsgWhitelistAddress | whitelist 추가 | COMPLIANCE_ADMIN |
| MsgRemoveWhitelist | whitelist 제거 | COMPLIANCE_ADMIN |
| MsgBlacklistAddress | blacklist 추가 | COMPLIANCE_ADMIN |
| MsgRemoveBlacklist | blacklist 제거 | COMPLIANCE_ADMIN |
| MsgFreezeAddress | 주소 동결 | COMPLIANCE_ADMIN |
| MsgUnfreezeAddress | 동결 해제 | COMPLIANCE_ADMIN |

## 5.5 Transfer Check

```text
CanTransfer(sender, receiver, denom, amount):
  if mode == BYPASS:
    return true
  if sender or receiver is frozen:
    return false
  if sender or receiver is blacklisted:
    return false
  if mode == BLACKLIST_ONLY:
    return true
  if mode == WHITELIST_REQUIRED:
    require sender and receiver whitelisted
  if mode == KYC_AML_REQUIRED:
    require sender and receiver KYC_VERIFIED and AML_CLEARED
```

## 5.6 Events

- compliance.mode_changed
- compliance.kyc_updated
- compliance.aml_updated
- compliance.whitelisted
- compliance.blacklisted
- compliance.frozen
- compliance.unfrozen

---

# 6. x/stablecoin

## 6.1 목적

다중 법정화폐 기반 stablecoin을 등록하고 mint/burn/pause를 관리한다.

## 6.2 Stablecoin Definition

| 필드 | 설명 |
|---|---|
| denom | base denom, 예: uusdx |
| display_name | 표시명, 예: USDX |
| fiat_currency | USD, GBP, EUR 등 |
| decimals | 소수점 자리수 |
| issuer | 발행 주체 주소 |
| max_supply | 최대 발행량 |
| paused | 전송 또는 발행 중지 여부 |
| mint_roles | minter 주소 목록 |
| burn_roles | burner 주소 목록 |
| fee_config | 수수료 정책 |
| swap_enabled | swap 가능 여부 |

## 6.3 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgCreateStablecoin | stablecoin 등록 | STABLECOIN_ADMIN |
| MsgUpdateStablecoin | 설정 수정 | STABLECOIN_ADMIN |
| MsgPauseStablecoin | 일시 중지 | STABLECOIN_ADMIN 또는 SUPER_ADMIN |
| MsgResumeStablecoin | 재개 | STABLECOIN_ADMIN 또는 SUPER_ADMIN |
| MsgMintStablecoin | 발행 | MINTER for denom |
| MsgBurnStablecoin | 소각 | BURNER for denom |
| MsgSetMintLimit | 발행 한도 설정 | STABLECOIN_ADMIN |

## 6.4 Mint/Burn Rules

- signer must have MINTER/BURNER role for denom.
- denom must not be paused.
- amount must not exceed max supply or mint limit.
- optional reserve check can be applied.

## 6.5 Queries

| Query | 설명 |
|---|---|
| QueryStablecoin | denom별 stablecoin 상세 |
| QueryStablecoins | 전체 stablecoin 목록 |
| QuerySupply | denom별 supply |
| QueryMintBurnHistory | 발행/소각 이력 |

## 6.6 Events

- stablecoin.created
- stablecoin.updated
- stablecoin.paused
- stablecoin.resumed
- stablecoin.minted
- stablecoin.burned

---

# 7. x/stableswap

## 7.1 목적

stablecoin 간 swap을 처리한다.

## 7.2 Swap Pair

| 필드 | 설명 |
|---|---|
| base_denom | 입력 또는 기준 denom |
| quote_denom | 출력 또는 상대 denom |
| rate | 교환 비율 |
| fee_rate | swap 수수료율 |
| fee_collector | 수수료 수취 주소 |
| enabled | pair 활성화 여부 |
| rate_source | ORACLE 또는 ADMIN |

## 7.3 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgCreateSwapPair | swap pair 생성 | SWAP_ADMIN |
| MsgUpdateSwapPair | pair 설정 변경 | SWAP_ADMIN |
| MsgSetExchangeRate | 환율 설정 | SWAP_ADMIN 또는 ORACLE |
| MsgSetSwapFee | 수수료 설정 | SWAP_ADMIN |
| MsgPauseSwapPair | pair 중지 | SWAP_ADMIN |
| MsgSwapExactIn | 정확한 input amount로 swap | user |
| MsgSwapExactOut | 정확한 output amount로 swap | user |

## 7.4 Fee Formula

```text
fee_amount = input_amount * fee_rate
net_input = input_amount - fee_amount
output_amount = net_input * exchange_rate
```

## 7.5 Events

- swap.pair_created
- swap.pair_updated
- swap.rate_updated
- swap.fee_updated
- swap.executed
- swap.pair_paused

---

# 8. x/feehandler

## 8.1 목적

여러 stablecoin을 fee denom으로 허용하고, 수수료를 지정 주소로 routing한다.

## 8.2 기능

- allowed fee denom 관리
- denom별 min gas price 관리
- fee collector address 관리
- fee type별 treasury routing
- fee history event emit

## 8.3 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgAddAllowedFeeDenom | fee denom 추가 | FEE_ADMIN |
| MsgRemoveAllowedFeeDenom | fee denom 제거 | FEE_ADMIN |
| MsgSetMinGasPrice | denom별 min gas price 설정 | FEE_ADMIN |
| MsgSetFeeCollector | fee collector 주소 설정 | FEE_ADMIN |
| MsgSetFeeDistributionRule | fee type별 분배 규칙 설정 | FEE_ADMIN |

## 8.4 Queries

| Query | 설명 |
|---|---|
| QueryAllowedFeeDenoms | 허용된 fee denom 목록 |
| QueryMinGasPrices | denom별 gas price |
| QueryFeeCollector | 수수료 수취 주소 |
| QueryFeeHistory | 수수료 이력 |

## 8.5 Events

- fee.denom_added
- fee.denom_removed
- fee.collected
- fee.collector_updated
- fee.distribution_updated

---

# 9. x/reserve

## 9.1 목적

스테이블코인의 준비금 보고와 검증 정보를 기록한다.

## 9.2 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgSubmitReserveReport | 준비금 보고 제출 | RESERVE_REPORTER |
| MsgVerifyReserveReport | 보고 검증 | AUDITOR 또는 RESERVE_REPORTER |
| MsgSetReserveRequirement | 준비율 정책 설정 | STABLECOIN_ADMIN |

## 9.3 Reserve Report Fields

| 필드 | 설명 |
|---|---|
| denom | stablecoin denom |
| reported_reserve | 보고된 준비금 |
| total_supply | 해당 시점 supply |
| reserve_ratio | 준비금 비율 |
| reporter | 보고자 |
| auditor | 검증자 optional |
| reference_hash | offchain report hash |
| timestamp | 보고 시점 |

---

# 10. x/oracle

## 10.1 목적

FX rate 또는 운영자 고시 환율을 chain에 제공한다.

## 10.2 Messages

| Msg | 설명 | 권한 |
|---|---|---|
| MsgSubmitFxRate | FX rate 제출 | ORACLE 또는 SWAP_ADMIN |
| MsgSetOracleSigner | oracle signer 설정 | SUPER_ADMIN |
| MsgRemoveOracleSigner | oracle signer 제거 | SUPER_ADMIN |

## 10.3 Events

- oracle.rate_submitted
- oracle.signer_added
- oracle.signer_removed

---

# 11. x/audit

## 11.1 목적

중요 운영 액션을 감사 가능하게 기록한다.

## 11.2 Audit 대상

| 이벤트 | 설명 |
|---|---|
| Role 변경 | 권한 부여/회수 |
| Validator 변경 | 추가/삭제/강제추방 |
| Mint/Burn | 발행/소각 |
| Compliance 변경 | blacklist/freeze/mode 변경 |
| Fee 설정 변경 | 수수료 정책 변경 |
| Swap 설정 변경 | pair/rate/fee 변경 |
| Emergency action | pause/unpause |

## 11.3 Queries

| Query | 설명 |
|---|---|
| QueryAuditLog | 조건별 audit log 조회 |
| QueryAuditLogByActor | actor별 이력 |
| QueryAuditLogByAction | action별 이력 |
| QueryAuditLogByTimeRange | 기간별 이력 |

