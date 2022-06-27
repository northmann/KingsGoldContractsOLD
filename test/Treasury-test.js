const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("Treasury", function () {

  let owner, addr1, addr2;
  let userAccountBeacon;
  let userAccountManager;
  let treasury;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    treasury = await builder.addTreasury(owner);
  });

  it('setGold', async () => {
    let goldAddress = await treasury.gold();
    expect(goldAddress).to.not.equal(ethers.constants.AddressZero);

    await treasury.setGold(owner.address);
    goldAddress = await treasury.gold();
    expect(goldAddress).to.equal(owner.address);

  });

});

