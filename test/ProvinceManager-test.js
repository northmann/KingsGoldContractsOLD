const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract } = require("./Auxiliary.js");


describe("ProvinceManager", function () {

  let owner, addr1, addr2;
  let userAccountBeacon;
  let userAccountManager;
  let token;
  let treasury;
  let userManager;
  let continentBeacon;
  let continentAddress;
  let world;
  let provinceManager;
  let provinceBeacon;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    userAccountBeacon = await createBeacon("UserAccount");
    userAccountManager = await createUpgradeable("UserAccountManager", [userAccountBeacon.address]);
    token = await deployContract("KingsGold");
    treasury = await createUpgradeable("Treasury", [userAccountManager.address, token.address]);
    continentBeacon = await createBeacon("Continent");
    world = await createUpgradeable("World", [userAccountManager.address, continentBeacon.address]);

    let tx = await world.createContinent(); // Make a continent
    await tx.wait(); // wait until the transaction is mined

    continentAddress = await world.continents(0);
    console.log("Continent address: ", continentAddress);

    provinceManager = await createUpgradeable("ProvinceManager", [userAccountManager.address]);
    provinceBeacon = await createBeacon("Province");
    provinceManager.setBeacon(provinceBeacon.address);
    provinceManager.setContinent(continentAddress);
  });

  it('setBeacon', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    let beaconAddress = await provinceManager.beaconAddress();
    expect(beaconAddress).to.equal(provinceBeacon.address); // Initialized address

    const tx = await provinceManager.setBeacon(owner.address); // Set it to Zero
    await tx.wait();

    beaconAddress = await provinceManager.beaconAddress();
    expect(beaconAddress).to.equal(owner.address);
  });


  it('setContinent', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    let currentAddress = await provinceManager.continent();
    expect(currentAddress).to.equal(continentAddress); // Initialized address

    const tx = await provinceManager.setContinent(owner.address); // Set it to Zero
    await tx.wait();

    currentAddress = await provinceManager.continent();
    expect(currentAddress).to.equal(owner.address);
  });

  it('mintProvince', async () => {
    console.log(owner.address);
    const tx = await provinceManager.mintProvince("Test", addr1.address);
    const result = await tx.wait();

    const balance = await provinceManager.balanceOf(addr1.address);
    expect(balance).to.equal(1);

    for (i = 0; i < balance; i++) {
      const tokenId = await provinceManager.tokenOfOwnerByIndex(addr1.address, i);
      console.log("Token ID: ", tokenId);
      const province = await provinceManager.provinces(tokenId);
      console.log("Province address: ", province);
      expect(province).to.not.equal(ethers.constants.AddressZero);
    }

    console.log(result);

    expect(1).to.equal(1);
  });

  it('addSvgResouces', async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const tx = await provinceManager.addSvgResouces(1, "Test");
    const result = await tx.wait();

    //console.log(result);

    expect(1).to.equal(1);
  });

  
});
/*
Get data!?

let toAddr = '0xBc25A51F63AA4Db0FFff0C34467c8EE6DCb2d0FC';
let incomingTokenTransferEvents = await book.getPastEvents('Transfer', { filter: {'to': toAddr}, fromBlock: 0, toBlock: 'latest'})
incomingTokenTransferEvents.forEach( (event) => console.log(event.returnValues.tokenId));

*/