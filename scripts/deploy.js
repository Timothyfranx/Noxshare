import hre from "hardhat";

async function main() {
  console.log("Deploying NoxShare Ecosystem...");

  const USDC_ADDRESS = "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"; 

  const NoxShareToken = await hre.ethers.getContractFactory("NoxShareToken");
  const token = await NoxShareToken.deploy("NoxShare Palm Grove", "NOXPG");
  await token.waitForDeployment();
  console.log("NoxShareToken deployed to:", await token.getAddress());

  const NoxShareVault = await hre.ethers.getContractFactory("NoxShareVault");
  const vault = await NoxShareVault.deploy(await token.getAddress(), USDC_ADDRESS);
  await vault.waitForDeployment();
  console.log("NoxShareVault deployed to:", await vault.getAddress());

  const NoxBidEngine = await hre.ethers.getContractFactory("NoxBidEngine");
  const engine = await NoxBidEngine.deploy();
  await engine.waitForDeployment();
  console.log("NoxBidEngine deployed to:", await engine.getAddress());

  console.log("Deployment complete!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
