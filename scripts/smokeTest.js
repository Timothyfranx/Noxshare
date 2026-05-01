import { createPublicClient, http } from "viem";
import { arbitrumSepolia } from "viem/chains";
import * as dotenv from "dotenv";
import fs from "fs";
import path from "path";

dotenv.config();

async function main() {
  const rpcUrl = process.env.ARBITRUM_SEPOLIA_RPC || "https://sepolia-rollup.arbitrum.io/rpc";
  const publicClient = createPublicClient({
    chain: arbitrumSepolia,
    transport: http(rpcUrl)
  });

  const noxShareAddress = "0x47b41bc77cedd9b0672797f689b53fe3bc333599";
  const tokenAddress = "0x337bfadd47442f9b47476cd2badfbbf38101da24";

  console.log("Running Smoke Test...");

  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));
  const tokenArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShareToken.sol/NoxShareToken.json"), "utf8"));

  // 1. Call getAuctionStatus()
  const auctionStatus = await publicClient.readContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: 'getAuctionStatus',
  });
  console.log("Auction Status:", auctionStatus);

  // 2. Call shareToken.name()
  const tokenName = await publicClient.readContract({
    address: tokenAddress,
    abi: tokenArtifact.abi,
    functionName: 'name',
  });
  console.log("Token Name:", tokenName);

  if (tokenName === "NoxShare Palm Grove") {
    console.log("SMOKE TEST: SUCCESS");
  } else {
    console.error("SMOKE TEST: FAILED - Token name mismatch");
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
