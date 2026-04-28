import { ethers } from "ethers";
import fs from "fs";
import "dotenv/config";

async function deploy() {
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "https://sepolia-rollup.arbitrum.io/rpc");
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    console.log("Deploying with wallet:", wallet.address);
    const balance = await provider.getBalance(wallet.address);
    console.log("Wallet Balance:", ethers.formatEther(balance), "ETH");

    if (balance === 0n) {
        throw new Error("Insufficient funds for deployment. Please fund your wallet with Arbitrum Sepolia ETH.");
    }

    const deployContract = async (name, args = []) => {
        const artifactPath = `./artifacts/contracts/${name}.sol/${name}.json`;
        if (!fs.existsSync(artifactPath)) {
            throw new Error(`Artifact not found at ${artifactPath}. Please run 'npx hardhat compile' first.`);
        }
        const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
        const contract = await factory.deploy(...args);
        await contract.waitForDeployment();
        console.log(`${name} deployed to:`, await contract.getAddress());
        return contract;
    };

    const noxShare = await deployContract("NoxShare");

    console.log("\nDeployment Successful!");
    console.log("NoxShare Address:", await noxShare.getAddress());
}

deploy().catch(console.error);
