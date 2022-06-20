const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable } = require("./Auxiliary.js");


describe("UserAccountManager", function () {

  let userAccountBeacon;
  let userAccountManager;

  beforeEach(async function () {
    userAccountBeacon = await createBeacon("UserAccount");
    userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
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

