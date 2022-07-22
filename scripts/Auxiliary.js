const { expect } = require("chai");
const { ethers } = require("hardhat");

var roles = undefined;


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

function getId(name) {
    return ethers.BigNumber.from((ethers.utils.keccak256(ethers.utils.toUtf8Bytes(name))));
}

async function getRoles() {
    if(!roles) 
        roles = await deployContract("Roles");
    return roles;
}

async function advanceTime(time) {
    await network.provider.send("evm_increaseTime", [time]);
}

async function advanceBlock() {
    await network.provider.send("evm_mine", []);
}

async function advanceTimeAndBlock(time) {
    await advanceTime(time);
    await advanceBlock();
    return Promise.resolve(ethers.provider.getBlock("latest"));
}

async function waitBlock(promise) {
    await (await promise).wait();
}

module.exports = {
    createBeacon,
    createUpgradeable,
    deployContract,
    getContractInstance,
    getId,
    getRoles,
    advanceTime,
    advanceBlock,
    advanceTimeAndBlock,
    waitBlock
  };
