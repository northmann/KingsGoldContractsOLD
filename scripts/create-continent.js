// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const Continent = await ethers.getContractFactory("Continent");

  // Setup a beacon for the Continent contract
  const beacon = await upgrades.deployBeacon(Continent);
  await beacon.deployed();
  console.log("Beacon deployed to:", beacon.address);

  // Create an instance of Continent
  const instance = await upgrades.deployBeaconProxy(beacon, Continent, [42]);
  await instance.deployed();
  console.log("Continent deployed to:", instance.address);
}

async function upgrade() {
  const ContinentV2 = await ethers.getContractFactory("ContinentV2");


  await upgrades.upgradeBeacon(BEACON_ADDRESS, ContinentV2);
  console.log("Beacon upgraded");

  // Point to the new Contract
  const instance = ContinentV2.attach(BOX_ADDRESS);
}

main();