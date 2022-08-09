const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getId, getContractInstance, advanceTime, waitBlock } = require("../scripts/Auxiliary.js");
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
    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    await builder.addKingsGold(owner);
    await builder.addTreasury(owner);
    await builder.addCommodities(owner);
    eventFactoryObject = await  builder.addEventFactory();
    world = await builder.addWorld();
    await builder.addContinent();
    await builder.addProvinceManager();

    farmTypeId = getId("FARM_STRUCTURE");

    

  });

  beforeEach(async function () {
      // Create a new Province to test on
      province = await builder.addProvince(owner);
  });

  describe("Security", function () {
  
    it('Province has province Role', async () => {
 
      let hasRole = await userAccountManager.hasRole(await roles.PROVINCE_ROLE(), province.address);

      expect(hasRole).to.equal(true);
    });

  });

  describe("Events", function () {

    describe("StructureEvent", function () {

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

    });

    
  // it('CreateYieldEvent', async () => {
  //   const [owner, addr1, addr2] = await ethers.getSigners();

  //   // Make sure that the owner can create the Events
  //   let roles = await getRoles();
  //   userAccountManager.grantRole(await roles.PROVINCE_ROLE(), owner.address);

  //   let yieldEventResult = await eventFactory.callStatic.CreateYieldEvent(provinceAddress, farm.address, owner.address, 1, 1, 0);
    
  //   expect(yieldEventResult).to.not.equal(ethers.constants.AddressZero);
  // });

    describe("PopulationEvent", function () {

      it('PriceForTime', async () => {

        let tx = await province.createGrowPopulationEvent(1, 10, 0);
        await tx.wait();

        let latestEvent = await getContractInstance( "PopulationEvent", await province.latestEvent());
        
        let price = await latestEvent.priceForTime(); // BigNumber, should be ... 1 ether!

        let bigPrice = ethers.BigNumber.from(price);
        console.log("BigPrice:", bigPrice);
        console.log("1 Ether :", ethers.constants.One);
        expect(bigPrice).to.equal(ethers.constants.WeiPerEther);
      });


      it('GrowPopulation', async () => {

        let committedManPower = 10;
        let populationTotalBefore = await province.populationTotal();
        console.log("Total population before: ",populationTotalBefore);

        let tx = await province.createGrowPopulationEvent(1, committedManPower, 0);
        await tx.wait();

        let latestEvent = await province.latestEvent();
        await (await province.payForTime(latestEvent)).wait();
        await (await province.completeEvent(latestEvent)).wait();

        let populationAvailable = await province.populationAvailable();
        let populationTotalAfter = await province.populationTotal();
        
        console.log("Total population after: ",populationTotalAfter);

        expect(populationTotalAfter.toNumber()).to.equal(populationTotalBefore.toNumber() + committedManPower);
      });

      it('GrowPopulation cancel', async () => {

        let committedManPower = 10;
        let populationTotalBefore = await province.populationTotal();
        console.log("Total population before: ",populationTotalBefore);

        let tx = await province.createGrowPopulationEvent(1, committedManPower, 0);
        await tx.wait();

        let populationAvailableAfter = await province.populationAvailable();
        expect(populationAvailableAfter.toNumber()).to.equal(populationTotalBefore.toNumber()-committedManPower);

        let latestEvent = await province.latestEvent();
        //await (await province.payForTime(latestEvent)).wait(); Do not pay
        await (await province.cancelEvent(latestEvent)).wait();

        let populationAvailable = await province.populationAvailable();
        let populationTotalAfter = await province.populationTotal();
        
        console.log("Total population after: ",populationTotalAfter);

        expect(populationAvailable.toNumber()).to.equal(populationTotalBefore.toNumber());
        expect(populationTotalAfter.toNumber()).to.equal(populationTotalBefore.toNumber());
      });

      it('GrowPopulation cancel after half time', async () => {

        let committedManPower = 10;
        let populationTotalBefore = await province.populationTotal();
        console.log("Total population before: ",populationTotalBefore);

        waitBlock( province.createGrowPopulationEvent(1, committedManPower, 0) );

        let populationAvailableAfter = await province.populationAvailable();
        expect(populationAvailableAfter.toNumber()).to.equal(populationTotalBefore.toNumber()-committedManPower);

        let latestEvent = await province.latestEvent();

        // suppose the current block has a timestamp of 01:00 PM
        let hours3 = (60 * 60 * 3);

        advanceTime(hours2);

        waitBlock( province.cancelEvent(latestEvent) );

        let populationAvailable = await province.populationAvailable();
        let populationTotalAfter = await province.populationTotal();
        
        console.log("Total population after: ",populationTotalAfter);

        //expect(populationAvailable.toNumber()).to.equal(populationTotalBefore.toNumber());
        expect(populationTotalAfter.toNumber()).to.equal(populationTotalBefore.toNumber() + Math.floor(committedManPower / 4));
      });
    });

  });

  describe("EventFactory", function () {

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



  
});
