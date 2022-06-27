const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId, deployContract } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


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
  let container;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    await builder.addTreasury(owner);
    await builder.addCommodities(owner);
    container = await  builder.addEventFactory();
  });

  beforeEach(async function () {
  });

  it('getStructureBeacon', async () => {
    let farmId = getId("FARM_STRUCTURE");

    // Tuple result (bool, address)
    let farmBeaconResult = await container.eventFactory.getStructureBeacon(farmId);

    expect(farmBeaconResult[1]).to.equal(container.farmBeacon.address);
  });


  it('CreateBuildEvent', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    world = await builder.addWorld();
    await builder.addContinent();
    await builder.addProvinceManager();
    province = await builder.addProvince(owner);

    // // Make sure that the owner can create the Events
    userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);

    let farmId = getId("FARM_STRUCTURE");

    let buildEventResult = await container.eventFactory.callStatic.CreateBuildEvent(province.address, farmId, 1, 0);
    
    expect(buildEventResult).to.not.equal(ethers.constants.AddressZero);
  });

  it('CreateYieldEvent', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    world = await builder.addWorld();
    await builder.addContinent();
    await builder.addProvinceManager();
    province = await builder.addProvince(owner);

    // // Make sure that the owner can create the Events
    userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);

    let farm = await deployContract("Farm"); // Dummy

    let yieldEventResult = await container.eventFactory.callStatic.CreateYieldEvent(province.address, farm.address, owner.address, 1, 0);
    
    expect(yieldEventResult).to.not.equal(ethers.constants.AddressZero);
  });

  
});
