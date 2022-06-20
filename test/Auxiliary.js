const { expect } = require("chai");
const { ethers } = require("hardhat");

async function createBeacon(contractName) {
    const Contract = await ethers.getContractFactory(contractName);
    beacon = await upgrades.deployBeacon(Contract);
    await beacon.deployed();
    console.log(`${contractName} beacon = ${beacon.address}`);
    return beacon;
}

async function createUpgradeable(contractName, params) {
    const Contract = await ethers.getContractFactory(contractName);
    instance = await upgrades.deployProxy(Contract, params);
    await instance.deployed();
    console.log(`${contractName} contract deployed to ${instance.address}`);
    return instance;
}

module.exports = {
    createBeacon,
    createUpgradeable
  };