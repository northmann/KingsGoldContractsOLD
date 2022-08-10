// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
const { getId, deployContract, createUpgradeable, createConfigFile } = require("../scripts/Auxiliary.js");
const { deployGame } = require("./builder.js");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
  provider = ethers.getDefaultProvider();
  oneEth = ethers.utils.parseEther("1");

  // Setup all the contracts
  await deployGame(owner);

  let filePath =__dirname+"\\..\\frontend\\src\\abi\\"; 
  await createConfigFile(filePath+"config.json");


  const metaMaskAddr = "0xEeB996A982DE087835e3bBead662f64BE228F531";
  tx = await owner.sendTransaction({
      to: metaMaskAddr,
      value: ethers.utils.parseEther("100") // 100 ether
    });

  await tx.wait();
  console.log("Test metamask address funded: ", metaMaskAddr);


  const account9 = "0xF046bCa0D18dA64f65Ff2268a84f2F5B87683C47";
  tx = await owner.sendTransaction({
    to: account9,
    value: ethers.utils.parseEther("100") // 100 ether
  });

  await tx.wait();
  console.log("Test account9 address funded: ", metaMaskAddr);




  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


module.exports = {
  main
};
