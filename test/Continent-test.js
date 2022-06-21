const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance } = require("./Auxiliary.js");


describe("Continent", function () {

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

    provinceManager = await createUpgradeable("ProvinceManager", [userAccountManager.address]);
    provinceBeacon = await createBeacon("Province");
    provinceManager.setBeacon(provinceBeacon.address);
    provinceManager.setContinent(continentAddress);

    continent.setProvinceManager(provinceManager.address);

  });

  it('CreateProvince', async () => {
    // GrantRole minter to the Continent contract so it can create new UserAccount as new Provinces are created.

    const roles = await deployContract("Roles");
    const minterRole = await roles.MINTER_ROLE();
    await userAccountManager.grantRole(minterRole, continentAddress);

    const eth1 = ethers.utils.parseUnits("1.0", "ether");
    let amount = ethers.utils.parseUnits("10.0", "ether"); // 10 eth
    await token.mint(owner.address, amount);        // Give me a lot of new coins
    await token.approve(continentAddress, amount);  // Approve Continent to spend my coins

    const tx = await continent.createProvince("Test");
    await tx.wait();
    
    // Check userAccount provinces
    const userAccountAddress = await userAccountManager.getUserAccount(owner.address);
    const userAccount = await getContractInstance("UserAccount", userAccountAddress);
    const provincesCount = await userAccount.provinceCount();
    expect(provincesCount).to.equal(1);

    const provinceAddress = await userAccount.getProvince(0);
    expect(provinceAddress).to.not.equal(ethers.constants.AddressZero);
    console.log(`UserAccount ${userAccountAddress} has a province ${provinceAddress}`);

    // Check gold account
    const ownerBalance = await token.balanceOf(owner.address);
    amount = amount.sub(eth1);
    expect(ownerBalance).to.equal(amount);
    console.log(`User Gold balance ${ethers.utils.formatEther(amount)}`);

    // Check treasury
    const treasuryBalance = await token.balanceOf(treasury.address);
    expect(treasuryBalance).to.equal(eth1);
  });

});

