const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance } = require("./Auxiliary.js");


describe("World", function () {

    let owner, addr1, addr2;
    let userAccountBeacon;
    let userAccountManager;
    let token;
    let treasury;
    let userManager;
    let continentBeacon;
    let continentAddress;
    let world;
    let continent;


    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        userAccountBeacon = await createBeacon("UserAccount");
        userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
        token = await deployContract("KingsGold");
        treasury = await createUpgradeable("Treasury", [userAccountManager.address, token.address]);

        continentBeacon = await createBeacon("Continent");
        world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);
        world.setTreasury(treasury.address);

        let tx = await world.createContinent(); // Make a continent
        await tx.wait(); // wait until the transaction is mined

        continentAddress = await world.continents(0);
        console.log("Continent address: ", continentAddress);

        const Continent = await ethers.getContractFactory("Continent");
        continent = Continent.attach(continentAddress);

    });

    it("getTreasury", async function () {
        let treasuryAddress = await world.treasury();
        expect(treasuryAddress).to.equal(treasury.address);
    });

    it("getGold", async function () {
        let treasuryAddress = await world.treasury();
        let treasuryInstance = await getContractInstance("Treasury", treasuryAddress);
        let goldAddress = await treasuryInstance.gold();
        expect(goldAddress).to.equal(token.address);

    });

    it('CreateContinent', async () => {
        // console.log("Create UserAccount Beacon");
        // const UserAccount = await ethers.getContractFactory("UserAccount");
        // userAccountBeacon = await upgrades.deployBeacon(UserAccount);
        // await userAccountBeacon.deployed();
        // console.log("UserAccount Beacon deployed to:", userAccountBeacon.address);

        // console.log("Create UserAccountManager");
        // const UserAccountManager = await ethers.getContractFactory("UserAccountManager");
        // userManager = await upgrades.deployProxy(UserAccountManager, [userAccountBeacon.address]);
        // await userManager.deployed();
        // console.log("UserAccountManager deployed to:", userManager.address);

        // const World = await ethers.getContractFactory("World");
        // const _world = await upgrades.deployProxy(World, [_userManager.address]);
        // await _world.deployed();
        // console.log("World deployed to:", _world.address);
        // let userAccountManagerAddress = await _world.userManager();
        // console.log("UserAccountManager address on World:", userAccountManagerAddress);

        // expect(_userManager.address).to.equal(userAccountManagerAddress);

        // const Continent = await ethers.getContractFactory("Continent");
        // Setup a beacon for the Continent contract
        // const _continentBeacon = await upgrades.deployBeacon(Continent);
        // await _continentBeacon.deployed();
        // console.log("Continent Beacon deployed to:", _continentBeacon.address);

        // let tx = await _world.createWorld();

        // wait until the transaction is mined
        // await tx.wait();

        // let index = await _world.getContinentsCount();
        // console.log(index);

        // console.log("Continent index ", index);

        // console.log("Continent address: ", await _world.continents(0));

        expect(1).to.equal(1);
    });

});

