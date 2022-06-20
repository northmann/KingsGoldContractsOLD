const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Continent", function () {

  let contract;
  let owner;
  let token;
  let treasury;
  let userManager;
  let Continent;
  let continentBeacon;
  let continentAddress;
  let world;

  beforeEach(async function () {
    //const [owner] = await ethers.getSigners();
    console.log("Start with UserAccountManager");

    const UserAccountManager = await ethers.getContractFactory("UserAccountManager");
    userManager = await upgrades.deployProxy(UserAccountManager);
    await userManager.deployed();
    console.log("UserAccountManager deployed to:", userManager.address);

    const Token = await ethers.getContractFactory("KingsGold");
    token = await Token.deploy();
    console.log("KingsGold deployed to:", token.address);

    const Treasury = await ethers.getContractFactory("Treasury");
    treasury = await upgrades.deployProxy(Treasury, [userManager.address, token.address]);
    await treasury.deployed();
    console.log("Treasury deployed to:", treasury.address);

    // Create the smart contract object to test from
    Continent = await ethers.getContractFactory("Continent");

    // Setup a beacon for the Continent contract
    //Contract = await ContinentFaktory.deploy();
    continentBeacon = await upgrades.deployBeacon(Continent);
    await continentBeacon.deployed();
    console.log("Continent Beacon deployed to:", continentBeacon.address);

    const World = await ethers.getContractFactory("World");
    world = await upgrades.deployProxy(World, [userManager.address]);
    await world.deployed();
    console.log("World deployed to:", world.address);

    let tx = await world.createWorld(continentBeacon.address);
    // wait until the transaction is mined
    await tx.wait();
    continentAddress = await world.continents(0);
    console.log("Continent address: ", continentAddress);
  });

  it('CreateProvince', async () => {
    expect(1).to.equal(1);
  });

});

