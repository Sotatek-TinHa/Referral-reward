import { expect } from "chai";
import { ethers } from "hardhat";
import { Authorization, ReferralReward } from "../typechain-types";

let referralReward: ReferralReward;
let authorization: Authorization;

describe("VerifySignature", function () {
  this.beforeEach(async () => {
    const Authorization = await ethers.deployContract("Authorization");
    await Authorization.waitForDeployment();
    const AuthorizationAddress = await Authorization.getAddress()

    const ReferralReward = await ethers.deployContract('ReferralReward', [AuthorizationAddress])
    await ReferralReward.waitForDeployment();

    referralReward = ReferralReward;
    authorization = Authorization;
  })

  it("Check signature", async function () {
    const accounts = await ethers.getSigners()

    // const PRIV_KEY = "0x..."
    // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0]
    const amount = ethers.parseEther("0.00001")
    const message = "Hello"
    const dummyMessage = "Dummy message"
    const requestId = 123

    console.log("signer address:", signer.address)

    const hash = await referralReward.createMessageHash(message, amount, amount, requestId)
    const signature = await signer.signMessage(ethers.toBeArray(hash))

    // Correct signature and message returns true
    expect(
      await authorization.authorize(
        signer.address,
        hash,
        signature
      )
    ).to.equal(true)

    const dummyHash = await referralReward.createMessageHash(dummyMessage, amount, amount, requestId)
    // Incorrect message returns false
    expect(
      await authorization.authorize(
        signer.address,
        dummyHash,
        signature
      )
    ).to.equal(false)
  })

  // it("Check withdraw", async function () {
  //   const accounts = await ethers.getSigners()

  //   // const PRIV_KEY = "0x..."
  //   // const signer = new ethers.Wallet(PRIV_KEY)
  //   const signer = accounts[0]
  //   const balance = ethers.parseEther("0.00001")
  //   const amount = ethers.parseEther("0.00001")
  //   const message = "Hello"
  //   const requestId = 123

  //   console.log("signer address:", signer.address)

  //   const hash = await referralReward.createMessageHash(message, amount, amount, requestId)
  //   const signature = await signer.signMessage(ethers.toBeArray(hash))

  //   // Correct signature and message returns true
  //   expect(
  //     await referralReward.withdraw({
  //       signer: signer.address,
  //       messageHash: "hash",
  //       availableBalance: balance,
  //       withdrawAmount: amount,
  //       requestId,
  //       signature
  //     })
  //   ).to.equal(false)

  //   // Incorrect message returns false
  //   expect(
  //     await referralReward.withdraw({
  //       signer: signer.address,
  //       messageHash: "hash",
  //       availableBalance: balance,
  //       withdrawAmount: amount,
  //       requestId,
  //       signature
  //     })
  //   ).to.equal(false)
  // })
});
