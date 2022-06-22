// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./GenericAccessControl.sol";
import "./Roles.sol";
import "./Continent.sol";
import "./KingsGold.sol";
import "./Treasury.sol";



contract World is Initializable, Roles, GenericAccessControl, UUPSUpgradeable {

    address private continentBeacon;
    address[] public continents;

    address public treasury;

    address public food;
    address public wood;
    address public iron;
    address public rock;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _userManager, address _continentBeacon) initializer public {
        __UUPSUpgradeable_init();
        userManager =_userManager; // Has to be set here, before anything else!
        continentBeacon = _continentBeacon;
    }

    function createContinent() external onlyRole(DEFAULT_ADMIN_ROLE) {
        //console.log("function: createWorld variable: _continentBeacon = ", continentBeacon);
        BeaconProxy proxy = new BeaconProxy(continentBeacon,abi.encodeWithSelector(Continent(address(0)).initialize.selector, "KingsGold Provinces", address(this), userManager));
        
        continents.push(address(proxy));

        //console.log("createContinent - now grant role to proxy");
        // Make sure that the mintProvince can create new UserAccounts.
        //UserAccountManager(userManager).grantRole(MINTER_ROLE, address(proxy));
        //console.log("createContinent - now grant role to proxy - Done!!!");
    }

    function getContinentsCount() external view returns(uint256) {
        return continents.length;
    }
    
        /// Upgrade the UserAccount template
    function upgradeContinentBeacon(address _beaconAddress) external onlyRole(UPGRADER_ROLE) {
        continentBeacon = _beaconAddress;
    }


    function setTreasury(address _treasuryAddress) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        treasury = _treasuryAddress;
    }

    function setFood(address _address) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        food = _address;
    }

    function setWood(address _address) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        wood = _address;
    }

    function setIron(address _address) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        iron = _address;
    }
    
    function setRock(address _address) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rock = _address;
    }


    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

}