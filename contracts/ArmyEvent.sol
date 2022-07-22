// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Event.sol";
import "./YieldStructure.sol";
import "./ResourceFactor.sol";
import "./Interfaces.sol";

import "./Continent.sol";
import "./Food.sol";

contract ArmyEvent is Initializable, IPopulationEvent, Event {
    uint256 constant ARMY_EVENT_ID = uint256(keccak256("ARMY_EVENT"));

    uint256 public totalShares;
    mapping(address => uint256) shares;
    IArmy public army;

    uint256 public timeBaseCost;
    uint256 public goldForTimeBaseCost;
    uint256 public foodBaseCost;

    function initialize(IProvince _fromProvince, IProvince _toProvince, IArmy army) initializer public {
        setupEvent(_fromProvince);

        _registerInterface(type(IArmyEvent).interfaceId);

        //multiplier = _multiplier;
        //manPower = _manPower;
        //hero = _hero;

        // Base values before multiplier and rounds
        rounds = 1; // Initial standard value
        multiplier = 1; // Initial standard value
        penalty = 50e16; // 50%
        attrition = 2e16; // 2%
        timeBaseCost = 1 hours; // Base cost of time to move between provinces.
        goldForTimeBaseCost = 1 ether; // Base cost of gold for time.
        foodBaseCost = 1 ether; // Base cost 1 unit of food for each unit of troop to move them

        _calculateCost();

        console.log("updatePopulation.creationTime: ", creationTime);

    }

    function addArmy(IArmyEvent _event) public returns(uint256) {
        // Merge the event into this one
        // return the shares!

    }

    function typeId() public pure override returns(uint256)
    {
        return ARMY_EVENT_ID;
    }

        /// The cost of the structures in total
    function _calculateCost() internal virtual
    {
        //timeRequired = timeRequired * rounds; // Change in manPower could alter this.
        //foodAmount = foodAmount * manPower * rounds;
    }




    function cancel() public override(IEvent, Event) onlyProvince notState(State.Minted) notState(State.Completed) notState(State.Cancelled)
    {
        state = State.Cancelled;
    }

    function updatePopulation() internal override
    {
        // Nothing happens here!
    }
}