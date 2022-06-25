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
import "./Interfaces.sol";


contract World is Initializable, Roles, GenericAccessControl, UUPSUpgradeable, IWorld {

    address private continentBeacon;
    IContinent[] public continents;

    IStructureManager internal structureManager;
    address public armyManager;

    ITreasury internal treasury;

    IFood public food;
    address public wood;
    address public iron;
    address public rock;

    uint256 public baseFactor; // The base price of the cost of everything.

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IUserAccountManager _userAccountManager, address _continentBeacon) initializer public {
        __setUserAccountManager(_userAccountManager);// Has to be set here, before anything else!
        __UUPSUpgradeable_init();
        continentBeacon = _continentBeacon;
        baseFactor = 1 ether; // The base cost, this value will change depending the on the blockchain. E.g. Ethereum would 0.001 ether and FTM would be 1 ether.
    }

    function createContinent() external onlyRole(DEFAULT_ADMIN_ROLE) {
        //console.log("function: createWorld variable: _continentBeacon = ", continentBeacon);
        BeaconProxy proxy = new BeaconProxy(continentBeacon,abi.encodeWithSelector(Continent(address(0)).initialize.selector, "KingsGold Provinces", address(this), userAccountManager));
        
        continents.push(IContinent(address(proxy)));

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
        treasury = ITreasury(_treasuryAddress);
    }

    function Treasury() public view override returns(ITreasury)
    {
        return treasury;
    }

    function setFood(address _address) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        food = IFood(_address);
    }

    function Food() public view override returns(IFood)
    {
        return food;
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


    function StructureManager() public view override returns(IStructureManager)
    {
        return structureManager;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

}