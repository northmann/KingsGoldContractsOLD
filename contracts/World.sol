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
    address public armyManager;

    IEventFactory public override eventFactory;
    ITreasury public override treasury;

    // The base price of the cost of everything.
    uint256 public override baseGoldCost;
    
    IFood public override food;
    IWood public override wood;
    IRock public override rock;
    IIron public override iron;

    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IUserAccountManager _userAccountManager, address _continentBeacon) initializer public {
        __setUserAccountManager(_userAccountManager);// Has to be set here, before anything else!
        __UUPSUpgradeable_init();
        continentBeacon = _continentBeacon;
        baseGoldCost = 1 ether; // The base cost, this value will change depending the on the blockchain. E.g. Ethereum would 0.001 ether and FTM would be 1 ether.
    }

    function createContinent() external onlyRole(DEFAULT_ADMIN_ROLE) {
        //console.log("function: createWorld variable: _continentBeacon = ", continentBeacon);
        BeaconProxy proxy = new BeaconProxy(continentBeacon,abi.encodeWithSelector(Continent(address(0)).initialize.selector, "KingsGold Provinces", address(this), userAccountManager));
        
        continents.push(IContinent(address(proxy)));

        //console.log("createContinent - now grant role to proxy");
        // Make sure that the mintProvince can create new UserAccounts.
        //UserAccountManager(userAccountManager).grantRole(MINTER_ROLE, address(proxy));
        //console.log("createContinent - now grant role to proxy - Done!!!");
    }

    function continentsCount() external view override returns(uint256) {
        return continents.length;
    }
    
        /// Upgrade the UserAccount template
    function upgradeContinentBeacon(address _beaconAddress) external override onlyRole(UPGRADER_ROLE) {
        continentBeacon = _beaconAddress;
    }

    function setEventFactory(IEventFactory _eventFactory) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        eventFactory = _eventFactory;
    }

    function setBaseGoldCost(uint256 _cost) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseGoldCost = _cost;
    }

    function setTreasury(address _treasuryAddress) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        treasury = ITreasury(_treasuryAddress);
    }

    function setFood(IFood _food) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        food = _food;
    }

    function setWood(IWood _wood) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        wood = _wood;
    }

    function setIron(IIron _iron) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        iron = _iron;
    }
    
    function setRock(IRock _rock) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rock = _rock;
    }


    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

}