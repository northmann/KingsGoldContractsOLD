// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
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
import "./FarmEvent.sol";
import "./Roles.sol";



contract Continent is Initializable, Roles, GenericAccessControl {

    string public name;
    uint256 constant provinceCost = 1 ether;

    address private userAccountManagerTemplate;
    address private provinceTemplate;
    address private armyTemplate;
    address private farmEventTemplate;

    address private provinceManager;
    address private armyManager;


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

        // userAccountManagerTemplate = address(new UserAccountManager());
        // userAccountManager = UserAccountManager(address(
        //     new ERC1967Proxy(
        //         userAccountManagerTemplate,
        //         abi.encodeWithSelector(UserAccountManager(address(0)).initialize.selector)
        //     )
        // )); 

        // provinceTemplate = address(new ProvinceManager());
        // provinceManager = ProvinceManager(address(
        //     new ERC1967Proxy(
        //         provinceTemplate,
        //         abi.encodeWithSelector(ProvinceManager(address(0)).initialize.selector)
        //     )
        // )); 

        // armyTemplate = address(new ArmyManager());
        // armyManager = ArmyManager(address(
        //     new ERC1967Proxy(
        //         armyTemplate,
        //         abi.encodeWithSelector(ArmyManager(address(0)).initialize.selector)
        //     )
        // )); 

        //farmEventTemplate = address(new FarmEvent());
        // armyManager = ArmyManager(address(
        //     new ERC1967Proxy(
        //         armyTemplate,
        //         abi.encodeWithSelector(ArmyManager(address(0)).initialize.selector)
        //     )
        // )); 
        
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

        console.log("createProvince - add province to user");
        user.addProvince(proxy);

        return tokenId;
    }

    function setProvinceManager(address _instance) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        provinceManager = _instance;
    }



    // function createHeroTransfer() external returns(address) {
    //     return address(0);
    // }

    // function addKnownContract(address _contract) internal {
    //     knownContracts[_contract] = 1;
    // }

    /// The user pays to reduce the time on a contract.
    function payForTime(address _contract) external {
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

    // function deposit(uint amount_) external {
    //     gold.transferFrom(msg.sender, address(gold), amount_);
    // }
}