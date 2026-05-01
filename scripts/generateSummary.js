import { createWalletClient, createPublicClient, http, parseEther } from "viem";
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
  const rpcUrl = "https://arbitrum-sepolia.drpc.org";

  const walletClient = createWalletClient({
    account,
    chain: arbitrumSepolia,
    transport: http(rpcUrl)
  });

  const publicClient = createPublicClient({
    chain: arbitrumSepolia,
    transport: http(rpcUrl)
  });

  const noxShareAddress = "0x1d5b629b0575631bbe10e29552e6bd9be11ce9e6";
  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));
  const noxClient = await createViemHandleClient(walletClient);

  console.log("1. Starting Auction...");
  const startTx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "startAuction",
    args: [3600n]
  });
  await publicClient.waitForTransactionReceipt({ hash: startTx });
  console.log("Auction Started:", startTx);

  console.log("2. Submitting Bid...");
  const { handle: bidHandle, handleProof: bidProof } = await noxClient.encryptInput(1000n, 'uint256', noxShareAddress);
  const bidTx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "submitBid",
    args: [bidHandle, bidProof]
  });
  await publicClient.waitForTransactionReceipt({ hash: bidTx });
  console.log("Bid Submitted:", bidTx);

  console.log("3. Minting Share...");
  const { handle: mintHandle, handleProof: mintProof } = await noxClient.encryptInput(500000n, 'uint256', noxShareAddress);
  const mintTx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "mintShare",
    args: [account.address, mintHandle, mintProof]
  });
  await publicClient.waitForTransactionReceipt({ hash: mintTx });
  console.log("Share Minted:", mintTx);

  console.log("SUMMARY:");
  console.log("Auction TX:", startTx);
  console.log("Bid TX:", bidTx);
  console.log("Mint TX:", mintTx);
}

main().catch(console.error);
