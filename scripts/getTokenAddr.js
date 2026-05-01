import { createPublicClient, http } from "viem";
import { arbitrumSepolia } from "viem/chains";
import fs from "fs";
import path from "path";

async function main() {
  const rpcUrl = "https://sepolia-rollup.arbitrum.io/rpc";
  const publicClient = createPublicClient({ chain: arbitrumSepolia, transport: http(rpcUrl) });
  
  const noxShareAddress = "0x47b41bc77cedd9b0672797f689b53fe3bc333599";
  const noxShareArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShare.sol/NoxShare.json"), "utf8"));

  const tokenAddr = await publicClient.readContract({
    address: noxShareAddress,
    abi: noxShareArtifact.abi,
    functionName: "shareToken"
  });
  
  console.log("TOKEN_ADDRESS=" + tokenAddr);
}
main().catch(console.error);
