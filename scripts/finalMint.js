import { createEthersHandleClient } from '@iexec-nox/handle';
import { JsonRpcProvider, Wallet, Contract } from 'ethers';
import * as dotenv from "dotenv";
import fs from "fs";
import path from "path";

dotenv.config();

async function main() {
  const rpcUrl = process.env.ARBITRUM_SEPOLIA_RPC || "https://sepolia-rollup.arbitrum.io/rpc";
  const provider = new JsonRpcProvider(rpcUrl);
  const signer = new Wallet(process.env.PRIVATE_KEY, provider);

  // Verify Chain ID
  const network = await provider.getNetwork();
  const chainId = network.chainId;
  console.log("Chain ID:", chainId.toString());
  if (chainId !== 421614n) {
    throw new Error(`Wrong network: expected 421614, got ${chainId}`);
  }

  const noxShareAddress = "0x6a97f480b676c94242df02b87535eda7cc8ec5a0";
  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));
  const noxShare = new Contract(noxShareAddress, noxShareArtifact.abi, signer);

  console.log("--- FINAL MINT ATTEMPT (ETHERS + AUTO-RESOLVE) ---");
  // No config needed — SDK auto-detects Arbitrum Sepolia
  const handleClient = await createEthersHandleClient(signer);

  console.log("applicationContract (NoxShare main):", noxShareAddress);

  // The user's prompt uses an object, but my local check showed positional.
  // I will try the user's way first, if it fails I will catch and try positional.
  let encryptionResult;
  try {
    console.log("Attempting object-based encryptInput...");
    encryptionResult = await handleClient.encryptInput({
      value: 500000n,
      solidityType: "uint256",
      applicationContract: noxShareAddress
    });
  } catch (err) {
    console.log("Object-based failed, trying positional arguments...");
    encryptionResult = await handleClient.encryptInput(
      500000n,
      "uint256",
      noxShareAddress
    );
  }

  const { handle, handleProof } = encryptionResult;
  console.log("Handle:", handle);
  console.log("Proof length:", handleProof.length);

  console.log("Sending mintShare()...");
  const tx = await noxShare.mintShare(signer.address, handle, handleProof);
  console.log("Mint Share TX Hash:", tx.hash);
  
  const receipt = await tx.wait();
  console.log("Minting Successful in block:", receipt.blockNumber);
  console.log("View on Arbiscan: https://sepolia.arbiscan.io/tx/" + tx.hash);
  
  console.log("--- SUCCESS ---");
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
