const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId, writeSetting } = require("./Auxiliary.js");

let owner, addr1, addr2;
let userAccountBeacon;
let userAccountManager;
let gold;
let food, wood, rock, iron;
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
let roles;
let farmBeacon;
let buildEventBeacon;
let yieldEventBeacon;
let populationEventBeacon;

const eth1 = ethers.utils.parseUnits("1.0", "ether");
let bigNumber100eth = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth
let bigNumber100Mill = ethers.utils.parseUnits("100000000.0", "ether"); // 100 mill eth

async function addRoles() {
    roles = await deployContract("Roles");
    //const minterRole = await roles.MINTER_ROLE();
    return roles;
}

async function addUserAccountManager() {
    userAccountBeacon = await createBeacon("UserAccount");
    userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);

    return userAccountManager;
}

async function addKingsGold(user) {
    if(!user) throw "Missing user instance";

    gold = await deployContract("KingsGold");

    return gold;
}


// Dependen on userAccountManager
async function addTreasury(user) {
    if(!user) throw "Missing user instance";
    if(!userAccountManager) throw "Missing userAccountManager instance";

    treasury = await createUpgradeable("Treasury", [userAccountManager.address, gold.address]);
    let treasuryGold = ethers.utils.parseUnits("100000000.0", "ether"); // 100 mill eth
    await gold.mint(treasury.address, bigNumber100eth);        // Give the treasury a lot of new coins
    await gold.mint(user.address, bigNumber100eth);        // Give the user a lot of new coins

    return treasury;
}

async function addCommodities(user) {
    if(!user) throw "Missing user instance";
    if(!userAccountManager) throw "Missing userAccountManager instance";

    food = await createUpgradeable("Food",[userAccountManager.address]);

    wood = await createUpgradeable("Wood",[userAccountManager.address]);

    rock = await createUpgradeable("Rock",[userAccountManager.address]);

    iron = await createUpgradeable("Iron",[userAccountManager.address]);

    return { food, wood, rock, iron };
}

async function mintCommodities(user) {
    await food.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await wood.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await rock.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await iron.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
}

async function addEventFactory() {
    if(!userAccountManager) throw "Missing userAccountManager instance";

    eventFactory = await createUpgradeable("EventFactory", [userAccountManager.address]);

    farmBeacon = await createBeacon("Farm");
    buildEventBeacon = await createBeacon("BuildEvent");
    yieldEventBeacon = await createBeacon("YieldEvent");
    populationEventBeacon = await createBeacon("PopulationEvent");

    if(farmBeacon) await eventFactory.setStructureBeacon(getId("FARM_STRUCTURE"), farmBeacon.address);
    if(buildEventBeacon) await eventFactory.setEventBeacon(getId("BUILD_EVENT"), buildEventBeacon.address);
    if(yieldEventBeacon) await eventFactory.setEventBeacon(getId("YIELD_EVENT"), yieldEventBeacon.address);
    if(populationEventBeacon) await eventFactory.setEventBeacon(getId("POPULATION_EVENT"), populationEventBeacon.address);

    return {eventFactory, farmBeacon, buildEventBeacon, yieldEventBeacon };
}


async function addWorld() {
    if(!userAccountManager) throw "Missing userAccountManager instance";

    continentBeacon = await createBeacon("Continent");
    world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);
    if(treasury)  await world.setTreasury(treasury.address);
    if(eventFactory) await world.setEventFactory(eventFactory.address);
    if(food)        await world.setFood(food.address);
    if(wood)        await world.setWood(wood.address);
    if(rock)        await world.setRock(rock.address);
    if(iron)        await world.setIron(iron.address);

    return world;
}

async function addContinent() {
    if(!userAccountManager) throw "Missing userAccountManager instance";
    if(!world) throw "Missing world instance";

    let tx = await world.createContinent(); // Make a continent
    await tx.wait(); // wait until the transaction is mined

    continentAddress = await world.continents(0);
    console.log("Continent address: ", continentAddress);
    writeSetting("Continent", continentAddress);

    await userAccountManager.grantRole(await roles.MINTER_ROLE(), continentAddress);

    const Continent = await ethers.getContractFactory("Continent");
    continent = Continent.attach(continentAddress);

    // Approve the continent to spend the owners coins
    if(gold) await gold.approve(continentAddress, bigNumber100Mill);  // Approve Continent to spend my coins
    if(food) await food.approve(continentAddress, bigNumber100Mill);  // Approve Continent to spend my coins
    if(wood) await wood.approve(continentAddress, bigNumber100Mill);  // Approve Continent to spend my coins
    if(rock) await rock.approve(continentAddress, bigNumber100Mill);  // Approve Continent to spend my coins
    if(iron) await iron.approve(continentAddress, bigNumber100Mill);  // Approve Continent to spend my coins

    return continent;
}

async function addProvinceManager() {
    if(!userAccountManager) throw "Missing userAccountManager instance";

    provinceManager = await createUpgradeable("ProvinceManager", [userAccountManager.address]);
    provinceBeacon = await createBeacon("Province");
    await provinceManager.setProvinceBeacon(provinceBeacon.address);

    if(continentAddress) await provinceManager.setContinent(continentAddress);
    if(continent)        await continent.setProvinceManager(provinceManager.address);

    return provinceManager;
}


async function addProvince(user) {
    if(!user) throw "Missing user instance";
    if(!continent) throw "Missing continent instance";
    if(!provinceManager) throw "Missing provinceManager instance";
    
    tx = await continent.createProvince("Test", user.address);
    let result = await tx.wait();

    provinceAddress = await provinceManager.provinces(0);
    province = await getContractInstance("Province", provinceAddress);

    return province;
}


async function deployMultiCall(owner, config, ...args) {
    const transactionCount = await owner.getTransactionCount()

    const futureAddress = ethers.utils.getContractAddress({
      from: owner.address,
      nonce: transactionCount
    });
  
    console.log("Next contract Multicall will be deployed to: ", futureAddress);
  
    multicall = await deployContract("Multicall");
    console.log("Multicall address: ", multicall.address);
  
    console.log("Next contract Multicall2 will be deployed to: ", futureAddress);
    multicall2 = await deployContract("Multicall2");
    console.log("Multicall2 address: ", multicall2.address);
}


async function deployGame(owner) {
    await deployMultiCall(owner);
    roles = await addRoles();
    userAccountManager = await addUserAccountManager();
    await addKingsGold(owner);
    await addTreasury(owner);
    await addCommodities(owner);
    eventFactoryObject = await addEventFactory();
    world = await addWorld();
    await addContinent();
    await addProvinceManager();
}



module.exports = {
    addRoles,
    addUserAccountManager,
    addKingsGold,
    addTreasury,
    addCommodities,
    mintCommodities,
    addEventFactory,
    addWorld,
    addContinent,
    addProvinceManager,
    addProvince,
    deployMultiCall,
    deployGame,
    goldAmount: bigNumber100eth,
  };
