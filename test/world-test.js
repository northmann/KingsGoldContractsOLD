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


    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        userAccountBeacon = await createBeacon("UserAccount");
        userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
        token = await deployContract("KingsGold");

        continentBeacon = await createBeacon("Continent");
        console.log("Creating world!");
        world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);

        treasury = await createUpgradeable("Treasury", [userAccountManager.address, token.address]);
        world.setTreasury(treasury.address);


    });

    beforeEach(async function () {
    });


    describe("Resources", function () {

        it("getTreasury", async function () {
            let treasuryAddress = await world.treasury();
            expect(treasuryAddress).to.equal(treasury.address);
        });

        it("getGold", async function () {
            let treasuryAddress = await world.treasury();
            let treasuryInstance = await getContractInstance("Treasury", treasuryAddress);
            let goldAddress = await treasuryInstance.Gold();
            expect(goldAddress).to.equal(token.address);

        });
    });

    describe("Actions", function () {

        it('CreateContinent', async () => {

            let tx = await world.createContinent(); // Make a continent
            await tx.wait(); // wait until the transaction is mined
    
            continentAddress = await world.continents(0);
            console.log("Continent address: ", continentAddress);
    
            let count = await world.continentsCount();
            expect(count).to.equal(1);
            
        });
    });

});

