const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId } = require("./Auxiliary.js");


describe("Food", function () {

    let owner, addr1, addr2;
    let userAccountBeacon;
    let userAccountManager;


    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        userAccountBeacon = await createBeacon("UserAccount");
        userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);

    });

    beforeEach(async function () {
    });


    describe("Resources", function () {

        it("createFood", async function () {
            let food = await createUpgradeable("Food",[userAccountManager.address]);
       
            expect(food.address).to.not.equal(ethers.constants.AddressZero);

        });
    });

  

});

