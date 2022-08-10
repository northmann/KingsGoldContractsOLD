// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >=0.8.4;
import "hardhat/console.sol";

// import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";



import "./GenericAccessControl.sol";
import "./World.sol";
import "./ProvinceManager.sol";
import "./Treasury.sol";
import "./KingsGold.sol";
import "./Interfaces.sol";
import "./UserAccountManager.sol";
import "./UserAccount.sol";
import "./Roles.sol";
import "./Food.sol";
import "./Event.sol";
import "./Errors.sol";




contract Continent is Initializable, Roles, GenericAccessControl, ReentrancyGuardUpgradeable, IContinent {
    string public name;
    IProvinceManager internal provinceManager;
    IWorld public override world;

    Config public config;
    //uint256 public baseProvinceCost = 1 ether; // The base cost, this value will change depending the on the blockchain. E.g. Ethereum would 0.001 ether and FTM would be 1 ether.
    //uint256 public baseCommodityReward = 100 ether; // The base reward for the commodities after buying a Province.
   
    modifier onlyProvince() {
        require(provinceManager.contains(msg.sender),"No Province in Continent"); //Event must be listed on the province's events.
        require(userAccountManager.hasRole(PROVINCE_ROLE, msg.sender), "Province missing role");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, IWorld _world, IUserAccountManager _userAccountManager) public initializer {
        //transferOwnership(tx.origin); // Now set ownership to the caller and not the world contract.
        __setUserAccountManager(_userAccountManager);// Has to be set here, before anything else!
        __ReentrancyGuard_init();
        name = _name;
        world = _world;
        config = Config({
            baseProvinceCost: 1 ether, // The base cost, this value will change depending the on the blockchain. E.g. Ethereum would 0.001 ether and FTM would be 1 ether.
            baseCommodityReward: 100 ether, // The base reward for the commodities after buying a Province.
            provinceLimit: 10
        });
    }

    function setConfig(Config memory _config) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        config = _config;
    }

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name, address owner) external override nonReentrant returns(uint256) {
        // TODO: Check name, no illegal chars


        // Make sure that the user account exist and if not then created it automatically.
        IUserAccount user = userAccountManager.ensureUserAccount(); // Just make sure that the user account exist!

        require(user.provinceCount() <= config.provinceLimit, "Cannot exeed the limit of provinces"); 

        ITreasury treasury = world.treasury();
        IKingsGold gold = treasury.gold();
        
        // Check if the user has enough money to pay for the province
        require(config.baseProvinceCost <= gold.balanceOf(msg.sender), "Not enough tokens in reserve");

        // Transfer gold from user to the treasury
        if(!gold.transferFrom(msg.sender, address(treasury), config.baseProvinceCost))
            revert("KingsGold transfer failed from sender to treasury.");


        // Create the province 
        (uint256 tokenId, IProvince province) = provinceManager.mintProvince(_name, owner);

        // Give the Provice the role of PROVINCE_ROLE, this will allow it to perform actions on other contrats.
        userAccountManager.grantProvinceRole(province); 
        
        // Add the province to the user account
        user.addProvince(province);

        // Mint resources to the user as a reward for creating a province.
        world.food().mint(msg.sender, config.baseCommodityReward);
        world.wood().mint(msg.sender, config.baseCommodityReward);
        world.rock().mint(msg.sender, config.baseCommodityReward);
        world.iron().mint(msg.sender, config.baseCommodityReward);

        return tokenId;
    }

    function setProvinceManager(IProvinceManager _instance) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        provinceManager = _instance;
    }


    // // Adds an event to a collaction to keep track of created events. Used for security.
    // function addEvent(address _event) public onlyRole(PROVINCE_ROLE) {
    //     require(ERC165Checker.supportsInterface(_event, type(IEvent).interfaceId), "Not a event contract");

    //     events.add(_event);
    // }

    // Spends the resouces of the event from the user account.
    // Only a province contract can call this function.
    function spendEvent(IEvent _event, address _user) public override onlyProvince nonReentrant {
        require(_user != address(0),"User cannot be empty");
        
        // Only the original caller can spend the event.
        require(_user == tx.origin,"Spending user must be the original caller"); 

        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not a event contract");
        IProvince province = _event.province();

        require(province.hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");
        require(province.containsEvent(_event),"Province has not registred the event");

        ITreasury treasury = world.treasury();
        console.log("spendEvent: treasury address : ", address(treasury));
        
        
        IFood food = world.food();
        console.log("spendEvent: food address : ", address(food));
        console.log("spendEvent: user (tx.origin) : ", _user);
        console.log("spendEvent: food amount : ", _event.foodAmount());
        
        if(_event.foodAmount() > 0) {
            // spend the resources that the event requires
            if(!world.food().transferFrom(_user, address(treasury), _event.foodAmount()))
                revert InsuffcientFood({
                    minRequired: _event.foodAmount()
                });
        }
        if(_event.woodAmount() > 0) {
            // spend the resources that the event requires
            if(!world.wood().transferFrom(_user, address(treasury), _event.woodAmount()))
                revert InsuffcientWood({
                    minRequired: _event.woodAmount()
                });
        }
        if(_event.rockAmount() > 0) {
            // spend the resources that the event requires
            if(!world.rock().transferFrom(_user, address(treasury), _event.rockAmount()))
                revert InsuffcientRock({
                    minRequired: _event.rockAmount()
                });
        }
        if(_event.ironAmount() > 0) {
            // spend the resources that the event requires
            if(!world.iron().transferFrom(_user, address(treasury), _event.ironAmount()))
                revert InsuffcientIron({
                    minRequired: _event.ironAmount()
                });
        }
    }

    // function createHeroTransfer() external returns(address) {
    //     return address(0);
    // }

    // function addKnownContract(address _contract) internal {
    //     knownContracts[_contract] = 1;
    // }

    /// The user pays to reduce the time on a contract.
    function payForTime(IEvent _event, address user) public override onlyProvince nonReentrant {

        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not an event contract");
        IProvince province = _event.province();
       
        require(province.hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");
        require(province.containsEvent(_event),"Province has not registred the event");

        uint256 timeCost = _event.priceForTime();
        ITreasury treasury = world.treasury();

        IKingsGold gold = treasury.gold();

        console.log("continent.payForTime: User=", user, " the value of ", timeCost);

        require(timeCost <= gold.balanceOf(user), "Not enough gold");

        if(!gold.transferFrom(user, address(treasury), timeCost))
            revert InsuffcientGold({
                minRequired: timeCost
            });
    }

    function completeMint(IYieldEvent _event) public override onlyProvince nonReentrant
    {
        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not an event contract");
        IProvince province = _event.province();
        require(address(province) == msg.sender,"Cannot be empty province");
        
        // require(province.hasRole(OWNER_ROLE, msg.sender) || province.hasRole(VASSAL_ROLE, msg.sender),"User is not owner or vassal on province");
        require(province.hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");
        require(province.containsEvent(_event),"Province has not registred the event");

        // give the _event permission to mint at wood, rock, food, iron.
        userAccountManager.grantTemporaryMinterRole(address(_event));

        IYieldEvent(address(_event)).completeMint();

        // remove the _event permission to mint at wood, rock, food, iron.
        userAccountManager.revokeTemporaryMinterRole(address(_event));

    }
}