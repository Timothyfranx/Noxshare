# iExec Tools Feedback: NoxShare Project

## Nox Protocol
- **What worked well:** The "Confidential Math" library (`Nox.add`, `Nox.gt`, etc.) is incredibly intuitive. It allowed us to transition from standard Solidity to privacy-preserving logic in a single afternoon. The separation between `euint256` handles and `externalEuint256` inputs is well-architected.
- **What was confusing or missing in docs:** The relationship between the `gatewayUrl` and the `smartContractAddress` in the `NOX_CONFIG` could be clearer, especially regarding how proofs are validated against specific gateway deployments.
- **Suggested improvements:** A local Hardhat node simulation for `Nox` operations would be a game-changer. Currently, debugging reverted `Nox` calls on-chain is time-consuming due to the lack of descriptive revert strings for encrypted comparisons.

## iExec SDK
- **What worked well:** The Viem integration via `@iexec-nox/handle` is excellent. It feels modern and fits perfectly into the current React/Wagmi ecosystem.
- **Pain points during integration:** The transition from Hardhat 2 to Hardhat 3 (which we used for this project) caused several plugin conflicts with the standard `@nomicfoundation/hardhat-toolbox`. We had to revert to standalone Viem scripts for deployment and smoke testing.
- **Suggested improvements:** Official support/templates for Hardhat 3 and ESM-based projects would help developers stay on the cutting edge of the Ethereum tooling stack.

## DataProtector
- **Experience using it for protected shares data:** Using DataProtector to secure the `shares.json` file for the TEE was a highlight. It provides a clear legal and technical bridge for RWA (Real World Asset) compliance.
- **Documentation quality:** Very high. The flow from "Protecting Data" to "Granting Access" to the TEE iApp is the most documented and easiest part of the stack to grasp.

## Overall
- **Would you use iExec again? Why?** Absolutely. Nox is the first protocol that makes "Confidential DeFi" feel like normal web development. It solves the "Public by Default" problem of the blockchain without requiring developers to become Zero-Knowledge researchers.

---
*NoxShare was built for the iExec Vibe Coding Challenge 2026.*
