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

  console.log("Submitting Bid...");
  const { handle, handleProof } = await noxClient.encryptInput(1000n, 'uint256', noxShareAddress);
  const tx = await walletClient.writeContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "submitBid",
    args: [handle, handleProof]
  });
  console.log("Bid TX Hash:", tx);
  await publicClient.waitForTransactionReceipt({ hash: tx });
  console.log("Bid Successful");
}

main().catch(console.error);
