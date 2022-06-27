const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("Commodities", function () {

  let owner, addr1, addr2;
  let userAccountBeacon;
  let userAccountManager;
  let treasury;
  let commodities;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    //roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    //treasury = await builder.addTreasury(owner);
    commodities = await builder.addCommodities(owner);

  });

  it('CheckAmount on food', async () => {
    let amount = await commodities.food.balanceOf(owner.address);
    expect(amount).to.equal(builder.goldAmount);
  });

  it('CheckAmount on wood', async () => {
    let amount = await commodities.wood.balanceOf(owner.address);
    expect(amount).to.equal(builder.goldAmount);
  });

  it('CheckAmount on rock', async () => {
    let amount = await commodities.rock.balanceOf(owner.address);
    expect(amount).to.equal(builder.goldAmount);
  });

  it('CheckAmount on iron', async () => {
    let amount = await commodities.iron.balanceOf(owner.address);
    expect(amount).to.equal(builder.goldAmount);
  });



});

