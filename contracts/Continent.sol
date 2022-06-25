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
import "./ArmyManager.sol";
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
    IWorld internal world;
   

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

    function World() public view override returns(IWorld)
    {
        return world;
    }

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name) external returns(uint256) {
        console.log("createProvince - Start");
        // Check name, no illegal chars
        IUserAccount user = userAccountManager.ensureUserAccount(); // Just make sure that the user account exist!

        console.log("createProvince - check user");

        require(user.provinceCount() <= 10, "Cannot exeed 10 provinces"); // Temp setup for now 4 june 2022

        console.log("createProvince - get treasury address");
        ITreasury treasury = world.Treasury();
        console.log("createProvince - get treasury");
        //Treasury tt = Treasury(treasuryAddress);
        console.log("createProvince - get Gold instance");
        IKingsGold gold = treasury.Gold();
        console.log("createProvince - check balanceOf user");
        require(provinceCost <= gold.balanceOf(msg.sender), "Not enough tokens in reserve");

        console.log("createProvince - transfer gold");
        if(!gold.transferFrom(msg.sender, address(treasury), provinceCost))
            revert();

        console.log("createProvince - mintProvince with ProvinceManager: ", address(provinceManager));

        (uint256 tokenId, IProvince province) = provinceManager.mintProvince(_name, tx.origin);

        console.log("createProvince - setProvinceRole: PROVINCE_ROLE");
        userAccountManager.grantProvinceRole(province); // Give the Provice the role of PROVINCE_ROLE, this will allow it to perform actions on other contrats.

        console.log("createProvince - add province to user");
        user.addProvince(province);

        return tokenId;
    }

    function setProvinceManager(IProvinceManager _instance) external override onlyRole(DEFAULT_ADMIN_ROLE)
    {
        provinceManager = _instance;
    }


    // // Adds an event to a collaction to keep track of created events. Used for security.
    // function addEvent(address _eventContract) public onlyRole(PROVINCE_ROLE) {
    //     require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

    //     events.add(_eventContract);
    // }

    function spendEvent(IEvent _eventContract) public override onlyRole(PROVINCE_ROLE) {
        require(ERC165Checker.supportsInterface(address(_eventContract), type(IEvent).interfaceId), "Not a event contract");

        ITreasury treasury = world.Treasury();
        
        IFood food = world.Food();
        // spend the resources that the event requires
        if(!food.transferFrom(tx.origin, address(treasury), _eventContract.FoodAmount()))
            revert InsuffcientFood({
                minRequired: _eventContract.FoodAmount()
            });

        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
    }




    function completeMint(address _eventContract) public override onlyRole(PROVINCE_ROLE) 
    {
        // require(provinceManager.containes(msg.sender)); // TODO: implement this functionality

        require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

        // give the _event permission to mint at wood, rock, food, iron.
        userAccountManager.grantTemporaryMinterRole(_eventContract);

        IEvent(_eventContract).completeMint();

        // remove the _event permission to mint at wood, rock, food, iron.
        userAccountManager.revokeTemporaryMinterRole(_eventContract);
    }


    // function createHeroTransfer() external returns(address) {
    //     return address(0);
    // }

    // function addKnownContract(address _contract) internal {
    //     knownContracts[_contract] = 1;
    // }

    /// The user pays to reduce the time on a contract.
    function payForTime(address _contract) public override onlyRole(PROVINCE_ROLE) {
        //check if contract is registred! 
        //require(knownContracts[_contract] != uint8(0), "Not known contract");
        require(ERC165Checker.supportsInterface(_contract, type(ITimeContract).interfaceId), "Not a time contract");

        ITimeContract timeContract = ITimeContract(_contract);
        uint256 timeCost = timeContract.priceForTime();
        ITreasury treasury = world.Treasury();

        IKingsGold gold = treasury.Gold();
        require(timeCost <= gold.balanceOf(msg.sender), "Not enough gold");

        if(!gold.transferFrom(msg.sender, address(treasury), timeCost))
            revert();

        timeContract.paidForTime();
    }
}