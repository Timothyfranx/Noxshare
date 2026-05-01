import { createWalletClient, createPublicClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { arbitrumSepolia } from "viem/chains";
import { createViemHandleClient } from "@iexec-nox/handle";
import * as dotenv from "dotenv";
import fs from "fs";
import path from "path";

dotenv.config();

async function main() {
  const privateKey = process.env.PRIVATE_KEY;
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

  // Verify Chain ID
  const chainId = await publicClient.getChainId();
  console.log("Chain ID:", chainId);
  if (chainId !== 421614) {
    throw new Error(`Wrong network: expected 421614, got ${chainId}`);
  }

  const noxShareAddress = "0x1d5b629b0575631bbe10e29552e6bd9be11ce9e6";
  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));

  console.log("--- FINAL MINT ATTEMPT (AUTO-RESOLVE SDK) ---");
  // NO config object needed — SDK auto-detects Arbitrum Sepolia
  const noxClient = await createViemHandleClient(walletClient);

  console.log("applicationContract (NoxShare main):", noxShareAddress);

  // HandleClient.encryptInput uses positional arguments
  const { handle, handleProof } = await noxClient.encryptInput(
    500000n,
    'uint256',
    noxShareAddress
  );
  console.log("Handle:", handle);

  console.log("Sending mintShare()...");
  const mintHash = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "mintShare",
    args: [account.address, handle, handleProof]
  });
  console.log("Mint Share TX Hash:", mintHash);
  
  const receipt = await publicClient.waitForTransactionReceipt({ hash: mintHash });
  console.log("Minting Successful in block:", receipt.blockNumber);
  console.log("View on Arbiscan: https://sepolia.arbiscan.io/tx/" + mintHash);
  
  console.log("--- SUCCESS ---");
}

main().catch(console.error);
