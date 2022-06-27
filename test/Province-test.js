const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("Province", function () {

  let userAccountManager;
  let province
  let roles;
  let provinceAddress;
  let world;
  let eventFactoryObject;
  let farmBeacon, buildEventBeacon, yieldEventBeacon;
  let farmTypeId;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    try {
      roles = await builder.addRoles();
      userAccountManager = await builder.addUserAccountManager();
      await builder.addTreasury(owner);
      await builder.addCommodities(owner);
      eventFactoryObject = await  builder.addEventFactory();
      world = await builder.addWorld();
      await builder.addContinent();
      await builder.addProvinceManager();
      province = await builder.addProvince(owner);
  
      farmTypeId = getId("FARM_STRUCTURE");
  
    } catch (error) 
    {
      console.log(error);
    }

    

  });

  beforeEach(async function () {
  });

  describe("Security", function () {
  
    it('Province has province Role', async () => {
 
      let hasRole = await userAccountManager.hasRole(await roles.PROVINCE_ROLE(), province.address);

      expect(hasRole).to.equal(true);
    });

  });

  describe("configuration", function () {

    it('setEventFactory', async () => {
      let tempEventFactory = await world.eventFactory();

      expect(tempEventFactory).to.equal(eventFactoryObject.eventFactory.address);
    });

    it('getStructureBeacon', async () => {
      // Tuple result (bool, address)
      let farmBeaconResult = await eventFactoryObject.eventFactory.getStructureBeacon(farmTypeId);

      expect(farmBeaconResult[1]).to.equal(eventFactoryObject.farmBeacon.address);
    });

  });



  it('createStructure', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Make sure that the owner can create the Events
    // let roles = await getRoles();
    // userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);
    console.log("Owner address: ", owner.address);

    //let province = await getContractInstance("Province", province.Address);


    //uint256 _structureId, uint256 _buildEventId, uint256 _count, uint256 _hero
    let tx = await province.createStructure(farmTypeId, 1, 0);
    await tx.wait();

    let data = await province.getEvents();

    console.log(data);
    //expect(buildEventResult).to.not.equal(ethers.constants.AddressZero);
  });

  // it('CreateYieldEvent', async () => {
  //   const [owner, addr1, addr2] = await ethers.getSigners();

  //   // Make sure that the owner can create the Events
  //   let roles = await getRoles();
  //   userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);

  //   let yieldEventResult = await eventFactory.callStatic.CreateYieldEvent(provinceAddress, farm.address, owner.address, 1, 0);
    
  //   expect(yieldEventResult).to.not.equal(ethers.constants.AddressZero);
  // });

  
});

// let owner, addr1, addr2;
// let userAccountBeacon;
// let userAccountManager;
// let token;
// let food;
// let treasury;
// let userManager;
// let continentBeacon;
// let continentAddress;
// let world;
// let provinceManager;
// let provinceBeacon;
// let provinceAddress;
// let eventFactory;
// let farm;
// let roles;
// let farmBeacon;
// let buildEventBeacon;
// let yieldEventBeacon;


    // userAccountBeacon = await createBeacon("UserAccount");
    // userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
    // token = await deployContract("KingsGold");
    
    // treasury = await createUpgradeable("Treasury", [userAccountManager.address, token.address]);
    // continentBeacon = await createBeacon("Continent");
    // world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);
    // world.setTreasury(treasury.address);

    // food = await createUpgradeable("Food",[userAccountManager.address]);
    // world.setFood(food.address);


    // let tx = await world.createContinent(); // Make a continent
    // await tx.wait(); // wait until the transaction is mined

    // continentAddress = await world.continents(0);
    // console.log("Continent address: ", continentAddress);

    // const Continent = await ethers.getContractFactory("Continent");
    // continent = Continent.attach(continentAddress);

    // provinceManager = await createUpgradeable("ProvinceManager", [userAccountManager.address]);
    // provinceBeacon = await createBeacon("Province");
    // provinceManager.setBeacon(provinceBeacon.address);
    // provinceManager.setContinent(continentAddress);

    // continent.setProvinceManager(provinceManager.address);

    // roles = await deployContract("Roles");
    // const minterRole = await roles.MINTER_ROLE();
    // await userAccountManager.grantRole(minterRole, continentAddress);

    // const eth1 = ethers.utils.parseUnits("1.0", "ether");
    // let amount = ethers.utils.parseUnits("10.0", "ether"); // 10 eth
    // await token.mint(owner.address, amount);        // Give me a lot of new coins
    // await token.approve(continentAddress, amount);  // Approve Continent to spend my coins

    // await food.mint(owner.address, amount);        // Give me a lot of new coins
    // await food.approve(continentAddress, amount);  // Approve Continent to spend my coins


    // tx = await continent.createProvince("Test", owner.address);
    // let result = await tx.wait();

    // provinceAddress = await provinceManager.provinces(0);

    // eventFactory = await createUpgradeable("EventFactory", [userAccountManager.address]);
    // eventFactory.setContinent(continentAddress);
    // world.setEventFactory(eventFactory.address);

    // farmBeacon = await createBeacon("Farm");
    // buildEventBeacon = await createBeacon("BuildEvent");
    // yieldEventBeacon = await createBeacon("YieldEvent");

    // farm = await deployContract("Farm"); // Dummy implementation

    // eventFactory.setStructureBeacon(await farm.Id(), farmBeacon.address);
    // eventFactory.setEventBeacon(getId("BUILD_EVENT"), buildEventBeacon.address);
    // eventFactory.setEventBeacon(getId("YIELD_EVENT"), yieldEventBeacon.address);
