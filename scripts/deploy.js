import { createWalletClient, createPublicClient, http, parseEther, getContractAddress } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { arbitrumSepolia } from "viem/chains";
import * as dotenv from "dotenv";
import fs from "fs";
import path from "path";

dotenv.config();

async function main() {
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) throw new Error("PRIVATE_KEY not found");
  const account = privateKeyToAccount(privateKey.startsWith('0x') ? privateKey : `0x${privateKey}`);
  const rpcUrl = process.env.ARBITRUM_SEPOLIA_RPC || "https://sepolia-rollup.arbitrum.io/rpc";

  const walletClient = createWalletClient({
    account,
    chain: arbitrumSepolia,
    transport: http(rpcUrl)
  });

  const publicClient = createPublicClient({
    chain: arbitrumSepolia,
    transport: http(rpcUrl)
  });

  console.log("Deploying NoxShare Ecosystem from:", account.address);

  // Helper to deploy a contract
  async function deployContract(name, args = []) {
    const artifactPath = path.resolve(`artifacts/contracts/${name}.sol/${name}.json`);
    const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
    
    console.log(`Deploying ${name}...`);
    const hash = await walletClient.deployContract({
      abi: artifact.abi,
      bytecode: artifact.bytecode,
      args
    });
    
    console.log(`Waiting for transaction: ${hash}`);
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    console.log(`${name} deployed to: ${receipt.contractAddress}`);
    return receipt.contractAddress;
  }

  // 1. Deploy NoxShareToken
  const tokenAddress = await deployContract("NoxShareToken");

  // 2. Deploy NoxShare with token address
  const noxShareAddress = await deployContract("NoxShare", [tokenAddress]);

  // 3. Transfer Ownership of Token to NoxShare
  console.log("Transferring NoxShareToken ownership to NoxShare...");
  const tokenArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShareToken.sol/NoxShareToken.json"), "utf8"));
  const hash = await walletClient.writeContract({
    address: tokenAddress,
    abi: tokenArtifact.abi,
    functionName: "transferOwnership",
    args: [noxShareAddress]
  });
  console.log(`Waiting for ownership transfer transaction: ${hash}`);
  await publicClient.waitForTransactionReceipt({ hash });
  console.log("Ownership transferred.");

  console.log("Deployment complete!");
  console.log("NoxShareToken:", tokenAddress);
  console.log("NoxShare:", noxShareAddress);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
