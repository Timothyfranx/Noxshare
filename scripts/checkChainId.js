import { createPublicClient, http } from "viem";
import { arbitrumSepolia } from "viem/chains";

async function main() {
  const rpcUrl = "https://sepolia-rollup.arbitrum.io/rpc";
  const publicClient = createPublicClient({ chain: arbitrumSepolia, transport: http(rpcUrl) });
  
  const chainId = await publicClient.getChainId();
  console.log("Chain ID:", chainId);
}
main().catch(console.error);
