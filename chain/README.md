# chain

Cosmos SDK private stablecoin chain component.

## Version Baseline

| Component | Version |
|---|---|
| Cosmos SDK | `v0.53.7` |
| Go | `1.25.12` |
| CometBFT | `v0.38.21` |
| Chain ID | `stablecoin-private-1` |
| Address Prefix | `stbc` |
| Initial Stablecoin | `USDX` / `uusdx` |

## MVP Modules

Initial custom modules planned for MVP:

- `x/authority`
- `x/stablecoin`
- `x/compliance`
- `x/feehandler`
- `x/audit`

See:

- `../docs/03_Chain_Module_Specification_v1.md`
- `../docs/07_Genesis_Policy_v1.md`
- `../docs/08_Tech_Stack_Versions_v1.md`
