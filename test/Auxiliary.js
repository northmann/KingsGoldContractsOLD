const { expect } = require("chai");
const { ethers } = require("hardhat");

async function createBeacon(contractName) {
    const Contract = await ethers.getContractFactory(contractName);
    const beacon = await upgrades.deployBeacon(Contract);
    await beacon.deployed();
    console.log(`${contractName} beacon = ${beacon.address}`);
    return beacon;
}

async function createUpgradeable(contractName, params) {
    const Contract = await ethers.getContractFactory(contractName);
    const instance = await upgrades.deployProxy(Contract, params);
    await instance.deployed();
    console.log(`${contractName} contract deployed to ${instance.address}`);
    return instance;
}

async function deployContract(contractName, ...args) {
    const Contract = await ethers.getContractFactory(contractName);
    const instance = await Contract.deploy(args);
    console.log(`${contractName} contract deployed to ${instance.address}`);

    return instance;
}

async function getContractInstance(name, contractAddress) {
    const Contract = await ethers.getContractFactory(name);
    instance = Contract.attach(contractAddress);
    return instance;
}

module.exports = {
    createBeacon,
    createUpgradeable,
    deployContract,
    getContractInstance
  };
