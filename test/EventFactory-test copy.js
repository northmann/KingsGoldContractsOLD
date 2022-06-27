const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getId, getRoles, getContractInstance } = require("./Auxiliary.js");


describe("EventFactory", function () {

  let owner, addr1, addr2;
  let userAccountBeacon;
  let userAccountManager;
  let token;
  let treasury;
  let userManager;
  let continentBeacon;
  let continentAddress;
  let world;
  let provinceManager;
  let provinceBeacon;
  let provinceAddress;
  let eventFactory;
  let farm;
  let farmBeacon;
  let buildEventBeacon;
  let yieldEventBeacon;

  before(async function () {
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

    provinceManager = await createUpgradeable("ProvinceManager", [userAccountManager.address]);
    provinceBeacon = await createBeacon("Province");
    provinceManager.setBeacon(provinceBeacon.address);
    provinceManager.setContinent(continentAddress);

    continent.setProvinceManager(provinceManager.address);

    tx = await provinceManager.mintProvince("Test", owner.address);
    let result = await tx.wait();

    provinceAddress = await provinceManager.provinces(0);

    eventFactory = await createUpgradeable("EventFactory", [userAccountManager.address]);
    eventFactory.setContinent(continentAddress);

    farmBeacon = await createBeacon("Farm");
    buildEventBeacon = await createBeacon("BuildEvent");
    yieldEventBeacon = await createBeacon("YieldEvent");

    farm = await deployContract("Farm");

    eventFactory.setStructureBeacon(await farm.Id(), farmBeacon.address);
    eventFactory.setEventBeacon(getId("BUILD_EVENT"), buildEventBeacon.address);
    eventFactory.setEventBeacon(getId("YIELD_EVENT"), yieldEventBeacon.address);

  });

  beforeEach(async function () {
  });


  it('checkId', async () => {
    let farmId = getId("FARM_STRUCTURE");
    
    let contractFarmId = await farm.Id();

    expect(contractFarmId).to.equal(farmId);
  });

  it('getStructureBeacon', async () => {
    let farmId = getId("FARM_STRUCTURE");

    // Tuple result (bool, address)
    let farmBeaconResult = await eventFactory.getStructureBeacon(farmId);

    expect(farmBeaconResult[1]).to.equal(farmBeacon.address);
  });


  it('build', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Make sure that the owner can create the Events
    let roles = await getRoles();
    userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);

    let farmId = await farm.Id();

    let buildEventResult = await eventFactory.callStatic.CreateBuildEvent(provinceAddress, farmId, getId("BUILD_EVENT"), 1, 0);
    
    expect(buildEventResult).to.not.equal(ethers.constants.AddressZero);
  });

  
});
