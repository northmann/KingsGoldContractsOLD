const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("World", function () {

  // let contract;
  // let owner;

  // beforeEach(async function () {
  //     // Create the smart contract object to test from
  //     [owner] = await ethers.getSigners();
  //     const TestContract = await ethers.getContractFactory("Test");
  //     contract = await TestContract.deploy();
  // });

  // it("Setup", async function () {
  //   const World = await ethers.getContractFactory("World");
  //   const _world = await upgrades.deployProxy(World);
  //   await _world.deployed();
  //   console.log("World deployed to:", _world.address);
  
  //   expect(true).to.equal(true);
  //   // const Greeter = await ethers.getContractFactory("Greeter");
  //   // const greeter = await Greeter.deploy("Hello, world!");
  //   // await greeter.deployed();

  //   // expect(await greeter.greet()).to.equal("Hello, world!");

  //   // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

  //   // // wait until the transaction is mined
  //   // await setGreetingTx.wait();

  //   // expect(await greeter.greet()).to.equal("Hola, mundo!");
  // }); 

  it('CreateContinent', async () => {



    const UserAccountManager = await ethers.getContractFactory("UserAccountManager");
    const _userManager = await upgrades.deployProxy(UserAccountManager);
    await _userManager.deployed();
    console.log("UserAccountManager deployed to:", _userManager.address);

    const World = await ethers.getContractFactory("World");
    const _world = await upgrades.deployProxy(World, [_userManager.address]);
    await _world.deployed();
    console.log("World deployed to:", _world.address);
    let userAccountManagerAddress = await _world.userManager();
    console.log("UserAccountManager address on World:", userAccountManagerAddress);

    expect(_userManager.address).to.equal(userAccountManagerAddress);
    
    const Continent = await ethers.getContractFactory("Continent");
    // Setup a beacon for the Continent contract
    const _continentBeacon = await upgrades.deployBeacon(Continent);
    await _continentBeacon.deployed();
    console.log("Continent Beacon deployed to:", _continentBeacon.address);

    let tx = await _world.createWorld(_continentBeacon.address);

    // wait until the transaction is mined
    await tx.wait();

    let index = await _world.getContinentsCount();
    console.log(index);

    console.log("Continent index ", index);

    console.log("Continent address: ", await _world.continents(0));
  
    expect(index).to.equal(1);
  });

});

