import hre from "hardhat";

async function main() {
  console.log("Deploying NoxShare Ecosystem...");

  const USDC_ADDRESS = "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"; 

  // 1. Deploy NoxShareToken
  const NoxShareToken = await hre.ethers.getContractFactory("NoxShareToken");
  const token = await NoxShareToken.deploy();
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("NoxShareToken deployed to:", tokenAddress);

  // 2. Deploy NoxShare with token address
  const NoxShare = await hre.ethers.getContractFactory("NoxShare");
  const noxShare = await NoxShare.deploy(tokenAddress);
  await noxShare.waitForDeployment();
  const noxShareAddress = await noxShare.getAddress();
  console.log("NoxShare deployed to:", noxShareAddress);

  // 3. Transfer Ownership of Token to NoxShare
  console.log("Transferring NoxShareToken ownership to NoxShare...");
  await token.transferOwnership(noxShareAddress);

  // Note: NoxShareVault and NoxBidEngine are omitted as they are not 
  // currently part of the active /contracts folder and logic.
  
  console.log("Deployment complete!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
