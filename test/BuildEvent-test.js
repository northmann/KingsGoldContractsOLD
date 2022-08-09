const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId } = require("../scripts/Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("BuildEvent", function () {

  let userAccountManager;
  let province
  let roles;
  let provinceAddress;
  let world;
  let efContainer;
  let farmBeacon, buildEventBeacon, yieldEventBeacon;
  let farmTypeId;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    await builder.addKingsGold(owner);
    await builder.addTreasury(owner);
    await builder.addCommodities(owner);
    efContainer = await  builder.addEventFactory();
    world = await builder.addWorld();
    await builder.addContinent();
    await builder.addProvinceManager();
    province = await builder.addProvince(owner);

    farmTypeId = getId("FARM_STRUCTURE");
  


    

  });

  beforeEach(async function () {
  });

  describe("Configuration", function () {
  
    it('Init', async () => {
 

      let tx = await province.createStructureEvent(farmTypeId, 1, 1, 0);
      await tx.wait();
      

      
      //expect(buildEventResult).to.not.equal(ethers.constants.AddressZero);
  

      //expect(hasRole).to.equal(true);
    });

  });

  // describe("configuration", function () {

  //   it('setEventFactory', async () => {
  //     let tempEventFactory = await world.eventFactory();

  //     expect(tempEventFactory).to.equal(eventFactoryObject.eventFactory.address);
  //   });

  //   it('getStructureBeacon', async () => {
  //     // Tuple result (bool, address)
  //     let farmBeaconResult = await eventFactoryObject.eventFactory.getStructureBeacon(farmTypeId);

  //     expect(farmBeaconResult[1]).to.equal(eventFactoryObject.farmBeacon.address);
  //   });

  // });


  
});

