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
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


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




contract Continent is Initializable, Roles, GenericAccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    //EnumerableSet.AddressSet private events;

    string public name;
    uint256 constant provinceCost = 1 ether;

    address public provinceTemplate;
    address public armyTemplate;

    address public structureManager;
    address private provinceManager;
    address private armyManager;

    address public food;


    //mapping(address => uint8) public knownContracts;

    address public world;
    //address public treasury;
    

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, address _world, address _userManager) public initializer {
        //transferOwnership(tx.origin); // Now set ownership to the caller and not the world contract.
        name = _name;
        world = _world;
        userManager = _userManager;
    }

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name) external returns(uint256) {
        console.log("createProvince - Start");
        // Check name, no illegal chars
        address userAccountAddress = UserAccountManager(userManager).ensureUserAccount(); // Just make sure that the user account exist!

        console.log("createProvince - check user");
        //UserAccount user = UserAccount(UserAccountManager(userAccountManager).getUserAccount(tx.origin));
        UserAccount user = UserAccount(userAccountAddress);
        require(user.provinceCount() <= 10, "Cannot exeed 10 provinces"); // Temp setup for now 4 june 2022

        console.log("createProvince - get treasury address");
        address treasuryAddress = World(world).treasury();
        console.log("createProvince - get treasury");
        Treasury tt = Treasury(treasuryAddress);
        console.log("createProvince - get Gold instance");
        KingsGold gold = KingsGold(tt.gold());
        console.log("createProvince - check balanceOf user");
        require(provinceCost <= gold.balanceOf(msg.sender), "Not enough tokens in reserve");

        console.log("createProvince - transfer gold");
        if(!gold.transferFrom(msg.sender, treasuryAddress, provinceCost))
            revert();

        console.log("createProvince - mintProvince with ProvinceManager: ", provinceManager);

        (uint256 tokenId, address proxy) = ProvinceManager(provinceManager).mintProvince(_name, tx.origin);

        console.log("createProvince - setProvinceRole: PROVINCE_ROLE");
        UserAccountManager(userManager).grantProvinceRole(proxy); // Give the Provice the role of PROVINCE_ROLE, this will allow it to perform actions on other contrats.

        console.log("createProvince - add province to user");
        user.addProvince(proxy);

        return tokenId;
    }

    function setProvinceManager(address _instance) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        provinceManager = _instance;
    }


    // // Adds an event to a collaction to keep track of created events. Used for security.
    // function addEvent(address _eventContract) public onlyRole(PROVINCE_ROLE) {
    //     require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

    //     events.add(_eventContract);
    // }

    function spendEvent(address _eventContract) public onlyRole(PROVINCE_ROLE) {
        require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

        address treasuryAddress = World(world).treasury();
        Event eventContract = Event(_eventContract);

        // spend the resources that the event requires
        if(!Food(food).transferFrom(tx.origin, treasuryAddress, eventContract.food()))
            revert InsuffcientFood({
                minRequired: eventContract.food()
            });

        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
        // if(!Food(food).transferFrom(msg.sender, treasuryAddress, eventContract.food()))
        //     revert();
    }




    function completeMint(address _eventContract) public onlyRole(PROVINCE_ROLE) 
    {
        // require(ProvinceManager(provinceManager).containes(msg.sender)); // TODO: implement this functionality
        require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

        // give the _event permission to mint at wood, rock, food, iron.
        UserAccountManager(userManager).grantTemporaryMinterRole(_eventContract);

        IEvent(_eventContract).completeMint();

        // remove the _event permission to mint at wood, rock, food, iron.
        UserAccountManager(userManager).revokeTemporaryMinterRole(_eventContract);
    }


    // function createHeroTransfer() external returns(address) {
    //     return address(0);
    // }

    // function addKnownContract(address _contract) internal {
    //     knownContracts[_contract] = 1;
    // }

    /// The user pays to reduce the time on a contract.
    function payForTime(address _contract) public onlyRole(PROVINCE_ROLE) {
        //check if contract is registred! 
        //require(knownContracts[_contract] != uint8(0), "Not known contract");
        require(ERC165Checker.supportsInterface(_contract, type(ITimeContract).interfaceId), "Not a time contract");

        ITimeContract timeContract = ITimeContract(_contract);
        uint256 timeCost = timeContract.priceForTime();
        address treasuryAddress = World(world).treasury();

        KingsGold gold = KingsGold(Treasury(treasuryAddress).gold());
        require(timeCost <= gold.balanceOf(msg.sender), "Not enough gold");

        if(!gold.transferFrom(msg.sender, treasuryAddress, timeCost))
            revert();

        timeContract.paidForTime();
    }
}