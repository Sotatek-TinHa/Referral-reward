import { ethers } from "hardhat";

async function main() {
  const Authorization = await ethers.deployContract("Authorization");
  await Authorization.waitForDeployment();
  const AuthorizationAddress = await Authorization.getAddress()

  const ReferralReward = await ethers.deployContract('ReferralReward', [AuthorizationAddress])
  await ReferralReward.waitForDeployment();
  const ReferralRewardAddress = await ReferralReward.getAddress()

  console.log(
    `Contract referral reward: ${ReferralRewardAddress}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});