const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance } = require("./Auxiliary.js");


describe("Treasury", function () {

  let owner, addr1, addr2;
  let userAccountBeacon;
  let userAccountManager;
  let token;
  let treasury;
  let userManager;
  let continentBeacon;
  let continentAddress;
  let world;
  let continent;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    userAccountBeacon = await createBeacon("UserAccount");
    userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
    token = await deployContract("KingsGold");
    treasury = await createUpgradeable("Treasury", [userAccountManager.address, token.address]);

    continentBeacon = await createBeacon("Continent");
    world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);

    let tx = await world.createContinent(); // Make a continent
    await tx.wait(); // wait until the transaction is mined

    continentAddress = await world.continents(0);
    console.log("Continent address: ", continentAddress);

    const Continent = await ethers.getContractFactory("Continent");
    continent = Continent.attach(continentAddress);

  });

  it('setGold', async () => {
    let goldAddress = await treasury.gold();
    expect(goldAddress).to.equal(token.address);

    await treasury.setGold(owner.address);
    goldAddress = await treasury.gold();
    expect(goldAddress).to.equal(owner.address);

  });

});

