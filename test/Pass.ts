import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import hre from "hardhat";
  
  describe("Pass", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
      const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
      const ONE_GWEI = 1_000_000_000;
  
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await hre.ethers.getSigners();

      const Token = await hre.ethers.getContractFactory("Token");
      const SemaphoreVerifier = await hre.ethers.getContractFactory("SemaphoreVerifier");
      const Pass = await hre.ethers.getContractFactory("Pass");

      const token = await Token.deploy();
      const semaphoreVerifier = await SemaphoreVerifier.deploy();

      const pass = await Pass.deploy(
        ONE_YEAR_IN_SECS,
        10,
        await token.getAddress(),
        await semaphoreVerifier.getAddress()
      );
  
      return { pass, ONE_YEAR_IN_SECS, owner, otherAccount };
    }

    describe("Buying", function () {
      describe("Zkp", function () {

      })
    });
    
  });
  