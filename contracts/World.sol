// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "./ProvinceBeacon.sol";
import "./Continent.sol";
import "./KingsGold.sol";
import "./Treasury.sol";

contract World is Ownable {

    address[] public continents;

    UpgradeableBeacon immutable private continentBeacon;

    Treasury public treasury;



    constructor(address _treasury) {
        treasury = Treasury(_treasury);
        continentBeacon = new UpgradeableBeacon(address(new Continent()));

        //transferOwnership(tx.origin); 
    }

    function createWorld() external onlyOwner returns(uint) {
        BeaconProxy proxy = new BeaconProxy(address(continentBeacon),abi.encodeWithSelector(Continent(address(0)).initialize.selector, "KingsGold Provinces", address(treasury)));

        continents.push(address(proxy));

        return continents.length;
    }

    function upgradeContinent(address _blueprint) external onlyOwner {
        continentBeacon.upgradeTo(_blueprint);
    }



}