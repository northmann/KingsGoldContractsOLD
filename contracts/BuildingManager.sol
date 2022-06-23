// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import "./Farm.sol";
import "./Building.sol";
import "./Roles.sol";
import "./Province.sol";
import "./GenericAccessControl.sol";
import "./BuildEvent.sol";


uint256 constant FARM_BUILDING_ID = uint256(keccak256("FARM_BUILDING"));

contract BuildingManager is
    Initializable,
    Roles,
    GenericAccessControl,
    UUPSUpgradeable
 {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    EnumerableMap.UintToAddressMap private buildingBeacons;
    EnumerableMap.UintToAddressMap private eventBeacons;

    address public continent;

    //override onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    function Build(address _province, uint256 _buildingId, uint256 _count, uint256 _hero) public onlyRole(PROVINCE_ROLE) returns(address) {
        Province provinceInstance = Province(_province);
        // Check access to province
        require(provinceInstance.hasRole(OWNER_ROLE, tx.origin) || provinceInstance.hasRole(VASSAL_ROLE, tx.origin), "No access");
        // Get existing building is exist, if not create a new but do not attach to province yet

        (bool buildingExist, address buildingAddress) = provinceInstance.getBuilding(_buildingId);
        if(!buildingExist) {
            BeaconProxy buildingProxy = new BeaconProxy(buildingBeacons.get(_buildingId),abi.encodeWithSelector(Building(address(0)).initialize.selector));
            buildingAddress = address(buildingProxy);
        }
        
        // Create an event
        //require(populationUsed <= populationAvailable, "not enough population");
        // check that the hero exist and is controlled by user.
        //populationAvailable = populationAvailable - populationUsed;

        //(address _provinceAddress, address _hero, uint256 _populationUsed, uint256 _provinceFarmYieldFactor, uint256 _attritionFactor) initializer public {
        BeaconProxy eventProxy = new BeaconProxy(eventBeacons.get(_buildingId), abi.encodeWithSelector(BuildEvent(address(0)).initialize.selector, 
            _province,
            buildingAddress,
            _count
         ));
        
        //Continent(continent).addEvent(address(proxy));
        return address(eventProxy);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

} 