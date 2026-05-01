import { createPublicClient, http } from "viem";
import { arbitrumSepolia } from "viem/chains";
import fs from "fs";
import path from "path";

async function main() {
  const rpcUrl = "https://sepolia-rollup.arbitrum.io/rpc";
  const publicClient = createPublicClient({ chain: arbitrumSepolia, transport: http(rpcUrl) });
  
  const tokenAddr = "0x337BFAdd47442f9b47476cD2BADFBbF38101dA24";
  const tokenArtifact = JSON.parse(fs.readFileSync(path.resolve("artifacts/contracts/NoxShareToken.sol/NoxShareToken.json"), "utf8"));

  const owner = await publicClient.readContract({
    address: tokenAddr,
    abi: tokenArtifact.abi,
    functionName: "owner"
  });
  
  console.log("TOKEN_OWNER=" + owner);
  console.log("EXPECTED_OWNER=0x47b41bc77cedd9b0672797f689b53fe3bc333599");
}
main().catch(console.error);
