// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";



//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./GenericAccessControl.sol";
import "./Roles.sol";
import "./ArmyData.sol";
import "./Interfaces.sol";
//import "./Statics.sol";

uint256 constant MILITIA_ID = uint256(keccak256("MILITIA_ID"));


contract Army is Initializable, ERC165Storage, Roles, GenericAccessControl, IArmy {
    using EnumerableSet for EnumerableSet.AddressSet;


    States public state;

    //uint public creationTime = block.timestamp;
    
    IContinent public continent;

    // Armies that have merge their troops into the this army.
    EnumerableSet.AddressSet private mergedArmies;  

    IArmy public mainArmy;

    IArmyUnits public units;

    //IProvince public currentProvince;   // The current province that the army is in. If the army is traveling, then the current Province is set but not arrived yet until time has passed.
    //IProvince public leavingProvince;   // If the army is traveling, then the leaving province was the form current province.

    enum States {
        Camping,
        Traveling,
        LayingSiege,
        Attacking,
        Merged,
        Disbanded,
        Destroyed
    }
    //EnumerableMap.UintToUintMap internal units;
    //mapping(address => EnumerableMap.UintToUintMap) shares; // Keep track off who has units in this army.

    address public owner;

    // uint256 public size; ?

    address public hero; // or token ID?

    //IArmyEvent public armyEvent;

    IEvent public armyEvent;

    // uint32 public militia;
    // uint32 public infantry;
    // uint32 public cavalry;
    // uint32 public archers;
    // uint32 public siegeWeapons;
    // uint32[10] private __nop;

    modifier onlyArmy() {
        require(userAccountManager.hasRole(ARMY_ROLE, msg.sender), "Army missing role");
        _;
    }

    modifier atStage(States _state) {
        require(state == _state);
        _;
    }

    modifier notStage(States _state) {
        require(state != _state);
        _;
    }
    modifier transitionAfter() {
        _;
        nextStage();
    }
    
    modifier timedTransitions() {
        // if (state == States.Traveling && block.timestamp >= creationTime + 6 days) {
        //     state = States.Camping;
        // }
        // if (state == States.RevealBids && block.timestamp >= creationTime + 10 days) {
        //     nextStage();
        // }
        _;
    }


    // modifier notTraveling() {
    //     if (state == States.Traveling && block.timestamp >= armyEvent.creationTime + 6 days) {
    //     require(state != _state);
    //     _;
    // }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _owner) initializer public {
        owner = _owner;
        _registerInterface(type(IArmy).interfaceId);
         state = States.Camping;
    }

    function addUnits(uint256 _unitId, uint256 _amount) public onlyArmy {
        //units[_unitId] += _amount;
        //shares[msg.sender] = 10;
    }

    function buildUnits(uint256 _unitId, uint256 _amount) public { // OnlyEvent

    }

    function _addUnits(uint256 _unitId, uint256 _amount, IArmy _army) internal {

    }



    

    function mergeArmy(IArmy _army) public notStage(States.Merged) {
        require(address(_army) != address(0), "Army cannot be empty");

        IArmyUnits units = continent.world().armyUnits();
        

    }

    // function bid() public payable timedTransitions atStage(States.AcceptingBlindBids) {
    //     // Implement biding here
    // }

    // function reveal() public timedTransitions atStage(States.RevealBids) {
    //     // Implement reveal of bids here
    // }

    // function claimGoods() public timedTransitions atStage(States.WinnerDetermined) transitionAfter {
    //     // Implement handling of goods here
    // }

    // function cleanup() public atStage(States.Finished) {
    //     // Implement cleanup of auction here
    // }
    
    function nextStage() internal {
        state = States(uint(state) + 1);
    }

}