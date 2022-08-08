// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >=0.8.4;
import "hardhat/console.sol";

// import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


import "./GenericAccessControl.sol";
import "./World.sol";
import "./ProvinceManager.sol";
//import "./ArmyNFT.sol";
import "./Treasury.sol";
import "./KingsGold.sol";
import "./Interfaces.sol";
import "./UserAccountManager.sol";
import "./UserAccount.sol";
import "./Roles.sol";
import "./Food.sol";
import "./Event.sol";
import "./Errors.sol";




contract Continent is Initializable, Roles, GenericAccessControl, IContinent {
    uint256 constant provinceCost = 1 ether;

    string public name;
    IProvinceManager internal provinceManager;
    IWorld public override world;
   
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
        name = _name;
        world = _world;
    }

    // function world() public view override returns(IWorld)
    // {
    //     return world;
    // }

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name, address owner) external override returns(uint256) {
        console.log("createProvince - Start");
        // Check name, no illegal chars
        IUserAccount user = userAccountManager.ensureUserAccount(); // Just make sure that the user account exist!

        console.log("createProvince - check user");

        require(user.provinceCount() <= 10, "Cannot exeed 10 provinces"); // Temp setup for now 4 june 2022

        console.log("createProvince - get treasury address");
        ITreasury treasury = world.treasury();
        console.log("createProvince - get treasury");
        //Treasury tt = Treasury(treasuryAddress);
        console.log("createProvince - get Gold instance");
        IKingsGold gold = treasury.gold();
        console.log("createProvince - check balanceOf user");
        require(provinceCost <= gold.balanceOf(msg.sender), "Not enough tokens in reserve");

        console.log("createProvince - transfer gold");
        if(!gold.transferFrom(msg.sender, address(treasury), provinceCost))
            revert("KingsGold transfer failed from sender to treasury.");

        console.log("createProvince - mintProvince with ProvinceManager: ", address(provinceManager));

        (uint256 tokenId, IProvince province) = provinceManager.mintProvince(_name, owner);

        console.log("createProvince - setProvinceRole: PROVINCE_ROLE");
        userAccountManager.grantProvinceRole(province); // Give the Provice the role of PROVINCE_ROLE, this will allow it to perform actions on other contrats.

        console.log("createProvince - add province to user address: ", address(user));
        user.addProvince(province);

        console.log("createProvince - Done - returning tokenId: ", tokenId);
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

    function spendEvent(IEvent _event, address _user) public override onlyProvince {
        require(_user != address(0),"User cannot be empty");
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
    function payForTime(IEvent _event, address user) public override onlyProvince {

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

    function completeMint(IYieldEvent _event) public override onlyProvince
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