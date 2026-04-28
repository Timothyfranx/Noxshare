# NoxShare: Private Fractional RWA Platform

Built for the **iExec Vibe Coding Challenge**. NoxShare enables confidential fractional ownership of productive land (e.g., Palm Groves) using the iExec Nox Protocol.

## 🚀 Track Focus
- **B2C (Everyone):** Private land shares for retail investors.
- **B2B SaaS (Some People):** Confidential yield distribution for property managers.

## 🛠 Tech Stack
- **Blockchain:** Arbitrum Sepolia
- **Privacy:** iExec Nox (TEE + Confidential Tokens ERC-7984)
- **AI:** ChainGPT (Yield Prediction & Compliance)
- **Frontend:** React + Wagmi + Viem

## 📂 Project Structure
- `/contracts`: Core NoxShare smart contracts using iExec SDK.
- `/scripts`: Deployment and interaction scripts.
- `/frontend`: Premium "Bloomberg-style" dashboard.

## 🏁 Quick Start

### 1. Prerequisites
- Node.js (v18+)
- Hardhat
- iExec Account & API Key

### 2. Installation
```bash
npm install
```

### 3. Deployment
Configure your `.env` with `PRIVATE_KEY` and `ARBITRUM_SEPOLIA_RPC`.
```bash
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

### 4. Running the Frontend
```bash
cd frontend
npm install
npm start
```

## 🔒 Confidentiality Features (No Mock Data)
- **ERC-7984 Integration:** Balances are stored as `bytes32` handles on-chain.
- **Sealed-Bid Auctions:** Bids are compared inside the TEE using `nox.gt()`.
- **Private Yield Splitter:** Dividends are calculated confidentially using `nox.mul()` and `nox.div()`.

## 📄 Feedback
Feedback for the iExec team can be found in `feedback.md`.
