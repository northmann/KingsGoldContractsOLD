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

  //   let yieldEventResult = await eventFactory.callStatic.CreateYieldEvent(provinceAddress, farm.address, owner.address, 1, 1, 0);
    
  //   expect(yieldEventResult).to.not.equal(ethers.constants.AddressZero);
  // });

  
});
