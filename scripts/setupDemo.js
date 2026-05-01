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
  if (!privateKey) throw new Error("PRIVATE_KEY not found");
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

  const noxShareAddress = "0x71c1b1977c3752836be5a093fcb6dafe417de941";
  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));
  const noxClient = await createViemHandleClient(walletClient);

  console.log("--- DEMO SETUP ---");
  console.log("Wallet:", account.address);

  // 1. Start a fresh auction (10 minute duration for demo)
  console.log("1. Starting Auction (24 hours)...");
  const startTx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "startAuction",
    args: [86400n]
  });
  await publicClient.waitForTransactionReceipt({ hash: startTx });
  console.log("Auction started! TX:", startTx);

  // 2. Mint a fresh share to the demo wallet
  console.log("2. Minting fresh share (50,000 NOXPG)...");
  const { handle, handleProof } = await noxClient.encryptInput(
    50000n, 
    'uint256', 
    noxShareAddress
  );
  
  const mintTx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "mintShare",
    args: [account.address, handle, handleProof]
  });
  await publicClient.waitForTransactionReceipt({ hash: mintTx });
  console.log("Share minted! Handle ready to decrypt. TX:", mintTx);

  console.log("--- SETUP COMPLETE ---");
  console.log("You can now record the video. The dashboard will show the active auction and a decryptable balance.");
}

main().catch(console.error);
