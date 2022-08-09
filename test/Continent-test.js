const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createBeacon, createUpgradeable, deployContract, getContractInstance } = require("./Auxiliary.js");
const builder = require("../scripts/builder.js");


describe("Continent", function () {

  let owner, addr1, addr2;

  let userAccountBeacon;
  let userAccountManager;
  let gold;
  let treasury;
  let userManager;
  let continentBeacon;
  let world;
  let continent;
  let commodities;
  let provinceManager;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    roles = await builder.addRoles();
    userAccountManager = await builder.addUserAccountManager();
    gold = await builder.addKingsGold(owner);
    treasury = await builder.addTreasury(owner);
    commodities = await builder.addCommodities(owner);
    eventFactoryObject = await  builder.addEventFactory();
    world = await builder.addWorld();
    continent = await builder.addContinent();
    provinceManager = await builder.addProvinceManager();

  });

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

  });

  it('CreateProvince', async () => {
    const eth1 = ethers.utils.parseUnits("10.0", "ether");
    let amount = ethers.utils.parseUnits("100.0", "ether"); // 10 eth
    await gold.mint(owner.address, amount);        // Give me a lot of new coins
    await gold.approve(continent.address, amount);  // Approve Continent to spend my coins

    const ownerBalanceBefore = await gold.balanceOf(owner.address);

    const tx = await continent.createProvince("Test", owner.address);
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
    const ownerBalanceAfter = await gold.balanceOf(owner.address);
    expect(ownerBalanceBefore.gt(ownerBalanceAfter)).to.equal(true);

    console.log(`User Gold balance ${ethers.utils.formatEther(ownerBalanceAfter)}`);

    // Check treasury
    // const treasuryBalance = await gold.balanceOf(treasury.address);
    // expect(treasuryBalance).to.equal(eth1);

    // Check commodities
    expect((await commodities.food.balanceOf(owner.address)).eq(amount)).to.equal(true);
    expect((await commodities.wood.balanceOf(owner.address)).eq(amount)).to.equal(true);
    expect((await commodities.rock.balanceOf(owner.address)).eq(amount)).to.equal(true);
    expect((await commodities.iron.balanceOf(owner.address)).eq(amount)).to.equal(true);

  });

});

