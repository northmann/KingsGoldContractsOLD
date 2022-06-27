const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("UserAccountManager", function () {

  let userAccountManager;
  let roles;

  beforeEach(async function () {
    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
  });

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {

    it('hasRole', async () => {
          const [owner, addr1, addr2] = await ethers.getSigners();

          //expect(await userAccountManager.hasRole(await roles.DEFAULT_ADMIN_ROLE(), owner.address )).to.equal(true);
          expect(await userAccountManager.hasRole(await roles.MINTER_ROLE(), owner.address )).to.equal(true);
          expect(await userAccountManager.hasRole(await roles.UPGRADER_ROLE(), owner.address )).to.equal(true);
      });

  });

  it('upgradeUserAccountBeacon', async () => {
    const tx = await userAccountManager.upgradeUserAccountBeacon(ethers.constants.AddressZero);
    await tx.wait();

    const beaconAddress = await userAccountManager.userAccountBeacon();
    expect(beaconAddress).to.equal(ethers.constants.AddressZero);
  });

  it('ensureUserAccount first call', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // console.log("Owner: ", owner.address);
    // console.log("ensureUserAccount()");
    
    const tx = await userAccountManager.ensureUserAccount();
    await tx.wait(); // wait until the transaction is mined

    const userAccountAddress = await userAccountManager.getUserAccount(owner.address);
    
    //console.log("UserAccount address: ", userAccountAddress);
    
    expect(userAccountAddress).to.not.equal(ethers.constants.AddressZero);
  });

  it('ensureUserAccount second call', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();
    
    const tx = await userAccountManager.ensureUserAccount();
    await tx.wait(); // wait until the transaction is mined

    // Call again but nothing should happen
    const tx2 = await userAccountManager.ensureUserAccount();
    await tx2.wait(); // wait until the transaction is mined

    const userAccountAddress = await userAccountManager.getUserAccount(owner.address);
    expect(userAccountAddress).to.not.equal(ethers.constants.AddressZero);
  });
});

