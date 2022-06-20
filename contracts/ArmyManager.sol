// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


import "./ArmyNFT.sol";
import "./Army.sol";

contract ArmyManager is ArmyNFT {

    UpgradeableBeacon public beacon;
    mapping(uint256 => address) public army;

    function initialize() initializer public override {
        super.initialize();

        beacon = new UpgradeableBeacon(address(new Army())); // Make a Province blueprint and set it to the Beacon
    }

    function mintArmy(address _owner) external onlyRole(MINTER_ROLE) returns(uint256) {
        uint256 tokenId = safeMint(_owner);
        
        BeaconProxy proxy = new BeaconProxy(address(beacon),abi.encodeWithSelector(Army(address(0)).initialize.selector, _owner));
        army[tokenId] = address(proxy);
        
        return tokenId;
    }

    function upgradeArmyTemplate(address _template) external onlyRole(UPGRADER_ROLE) {
        beacon.upgradeTo(_template);
    }
}
