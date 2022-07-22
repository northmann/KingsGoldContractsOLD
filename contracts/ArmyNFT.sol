// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";


import "./GenericNFT.sol";
import "./Army.sol";
import "./Roles.sol";

contract ArmyManager is Initializable, GenericNFT, IArmyNFT {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    address public beaconAddress;
    mapping(uint256 => address) public army;
        EnumerableMap.AddressToUintMap internal lookup;



    function initialize(IUserAccountManager _userUserManager) initializer override public {
        super.initialize(_userUserManager); // Call parent GenericNFT
        __ERC721_init("KingsGold Army BFT", "KSGA");
    }

    function setArmyBeacon(address _template) external override onlyRole(UPGRADER_ROLE) {
        beaconAddress = _template;
    }


    function mintArmy(address _owner) external override onlyRole(MINTER_ROLE) returns(uint256) {
        uint256 tokenId = safeMint(_owner);
        
        BeaconProxy proxy = new BeaconProxy(beaconAddress   ,abi.encodeWithSelector(Army(address(0)).initialize.selector ));
        army[tokenId] = address(proxy);
        lookup.set(address(proxy), tokenId);

        
        return tokenId;
    }
}
