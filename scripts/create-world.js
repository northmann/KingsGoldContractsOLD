const { ethers, upgrades } = require("hardhat");

async function world_deploy() {
  const World = await ethers.getContractFactory("World");
  const _world = await upgrades.deployProxy(World);
  await _world.deployed();
  console.log("World deployed to:", _world.address);

  const continentBeaconAddress = createContinentBeacon();
  let index = await _world.createWorld(continentBeaconAddress);

  console.log("Continent index ", index);
}

async function createContinentBeacon() {
    const Continent = await ethers.getContractFactory("Continent");

    // Setup a beacon for the Continent contract
    const beacon = await upgrades.deployBeacon(Continent);
    await beacon.deployed();
    console.log("Beacon deployed to:", beacon.address);
  
    // Create an instance of Continent
    // const instance = await upgrades.deployBeaconProxy(beacon, Continent, [42]);
    // await instance.deployed();
    // console.log("Continent deployed to:", instance.address);
    return beacon.address;
}


world_deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  
module.exports = {
  world_deploy
};