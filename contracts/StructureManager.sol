// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

//import "./Farm.sol";
import "./YieldEvent.sol";
import "./BuildEvent.sol";
import "./Structure.sol";
import "./Roles.sol";
import "./Interfaces.sol";
import "./GenericAccessControl.sol";

uint256 constant YIELD_EVENT_ID = uint256(keccak256("YIELD_EVENT"));

contract StructureManager is
    Initializable,
    Roles,
    GenericAccessControl,
    UUPSUpgradeable,
    IStructureManager
 {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    EnumerableMap.UintToAddressMap private structureBeacons;
    EnumerableMap.UintToAddressMap private eventBeacons;

    address public continent;

    function initialize(address _userManager) initializer public virtual {
        __setUserAccountManager(_userManager);// Has to be set here, before anything else!
        __UUPSUpgradeable_init();
    }

    //override onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    function Build(address _province, uint256 _structureId, uint256 _count, uint256 _hero) public override onlyRole(PROVINCE_ROLE) returns(address) {
        IProvince provinceInstance = IProvince(_province);
        // Check access to province
        require(provinceInstance.hasRole(OWNER_ROLE, tx.origin) || provinceInstance.hasRole(VASSAL_ROLE, tx.origin), "No access");
        // Get existing structure is exist, if not create a new but do not attach to province yet

        (bool structureExist, address structureAddress) = provinceInstance.getStructure(_structureId);
        if(!structureExist) {
            BeaconProxy structureProxy = new BeaconProxy(structureBeacons.get(_structureId),abi.encodeWithSelector(Structure(address(0)).initialize.selector));
            structureAddress = address(structureProxy);
        }
        
        // Create an event
        //require(populationUsed <= populationAvailable, "not enough population");
        // check that the hero exist and is controlled by user.
        //populationAvailable = populationAvailable - populationUsed;

        //(address _provinceAddress, address _hero, uint256 _populationUsed, uint256 _provinceFarmYieldFactor, uint256 _attritionFactor) initializer public {
        BeaconProxy eventProxy = new BeaconProxy(eventBeacons.get(_structureId), abi.encodeWithSelector(BuildEvent(address(0)).initialize.selector, 
            _province,
            structureAddress,
            _count
         ));
        
        return address(eventProxy);
    }

    function CreateYieldEvent(address _province, address _structure, address _receiver, uint256 _count, uint256 _hero) public onlyRole(PROVINCE_ROLE) returns(address) {
        IProvince provinceInstance = IProvince(_province);
        // Check access to province
        require(provinceInstance.hasRole(OWNER_ROLE, tx.origin) || provinceInstance.hasRole(VASSAL_ROLE, tx.origin), "No access");
        // Get existing structure is exist, if not create a new but do not attach to province yet

        BeaconProxy eventProxy = new BeaconProxy(eventBeacons.get(YIELD_EVENT_ID), abi.encodeWithSelector(YieldEvent(address(0)).initialize.selector, 
            _province,
            _receiver, // receiver
            _structure,
            _count,
            _hero
         ));

         // Spend the resources for the event!
        
        return address(eventProxy);
    }

    function setContinent(address _continent) external onlyRole(DEFAULT_ADMIN_ROLE) {
        continent = _continent;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

} 