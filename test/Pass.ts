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
  
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await hre.ethers.getSigners();

      console.log("HERE");
      const Token = await hre.ethers.getContractFactory("Token");
      const SemaphoreVerifier = await hre.ethers.getContractFactory("SemaphoreVerifier");
      const Pass = await hre.ethers.getContractFactory("Pass");

      const token = await Token.deploy();
      const semaphoreVerifier = await SemaphoreVerifier.deploy();

      const pass = await Pass.deploy(
        ONE_YEAR_IN_SECS,
        0,
        await token.getAddress(),
        await semaphoreVerifier.getAddress(),
        "app_14d0217a5ec381effeb27d036b7c6c63",
        "rust-test"
      );
  
      return { pass, ONE_YEAR_IN_SECS, owner, otherAccount };
    }

    describe("Buying", function () {
      it("Zkp", async function () {
        let { pass, owner }  = await deployOneYearLockFixture();
        console.log("HERE");
        await pass.buyPass(
          '0xf43fd23dc34603363c3cb0b17c23f5abfe0997a6',
          1,
          '0x232391074ef3573bc2daf73742bd73211bc9d6c06a28f482dacb9cf56c3c4038',
          '0x1bca44f083f42000d0e421bee47e5b0619ccb96b937ae773840e325af300d8b8',
          '0x26b6d29845449602b1bed71bf7eb07dba524fd799e97fc18de7392039ee258f70d82153188560b5b8f9faddd7dba2241dceb059899bd0bd7f82486a2462b31450d8db0cd95bbd84cd69f2d859f16423dc94c11390a72b4411d12ba59f77cd7551f0d7355fac011a3cd18fe1f4ea27a98371ca665634b7d3e62c60130ecb0fe191edfb3199f9abc26e3bae76ef2fe7a2108ddd70e9dc7ec773efc6e07397c14911037b74db5304c9470d631e43b549ffcb7a31566f717c8dd5d608298b32c934106c4f197d345c1960d21b290bc12f4dfb90c4cd9c6ea9ed7fdfc96307785e0552075fd744540acbf894ebf228c0e6f84004a9d5a44c0045110bae2ba8f37884f'
        );
      })
    });
    
  });
  