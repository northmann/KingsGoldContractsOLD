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

contract YieldEvent is Initializable, IYieldEvent, Event {
    uint256 constant YIELD_EVENT_ID = uint256(keccak256("YIELD_EVENT"));

    IYieldStructure public override structure;
    address public receiver;


    function initialize(IProvince _province, IYieldStructure _structure, address _receiver, uint256 _multiplier, uint256 _rounds, address _hero) initializer public {
        setupEvent(_province);

        _registerInterface(type(IYieldEvent).interfaceId);

        structure = _structure;
        receiver = _receiver;
        multiplier = _multiplier;
        rounds = _rounds;
        hero = _hero;

        _calculateCost();
    }

    function typeId() public pure override returns(uint256)
    {
        return YIELD_EVENT_ID;
    }

        /// The cost of the structures in total
    function _calculateCost() internal virtual
    {
        // (uint256 manPowerFactor,
        // uint256 attritionFactor,
        // uint256 timeFactor,
        // uint256 goldForTimeFactor,
        // uint256 foodFactor,
        // uint256 woodFactor,
        // uint256 rockFactor,
        // uint256 ironFactor) = IYieldStructure(structure).rewardFactor();
        ResourceFactor memory factor = structure.rewardFactor();

        manPower = multiplier * factor.manPower; // The cost in manPower
        attrition = factor.attrition;
        penalty = factor.penalty;
        timeRequired = factor.time * rounds; // Change in manPower could alter this.
        goldForTime = factor.goldForTime;
        foodAmount = multiplier * factor.food;
        woodAmount = multiplier * factor.wood;
        rockAmount = multiplier * factor.rock;
        ironAmount = multiplier * factor.iron;
    }


    function completeMint() public override virtual timeExpired onlyMinter notState(State.Completed) notState(State.Minted)
    {
        // Reward the user with commodities
        if(foodAmount > 0) {
            world.food().mint_with_temp_account(receiver,foodAmount);
        }
        if(woodAmount > 0) {
            world.wood().mint_with_temp_account(receiver,woodAmount);
        }
        if(rockAmount > 0) {
            world.rock().mint_with_temp_account(receiver,rockAmount);
        }
        if(ironAmount > 0) {
            world.iron().mint_with_temp_account(receiver,ironAmount);
        }

        state = State.Minted;
    }

    // function cancel() public override(IEvent, Event) onlyProvince notState(State.Minted) notState(State.Completed) notState(State.Cancelled)
    // {
    //     // E.g;
    //     // Calculate penalty
    //     //penalizeCommodities();
    //     //mint()
    //     updatePopulation();

    //     //updatePopulation();
    //     state = State.Cancelled;
    // }

    function penalizeCommodities() public override onlyProvince notState(State.Minted) notState(State.Completed) notState(State.Cancelled) {
        foodAmount = penalizeAmount(foodAmount); // Reduce the yield by time and penalty.
        woodAmount = penalizeAmount(woodAmount); // Reduce the yield by time and penalty.
        rockAmount = penalizeAmount(rockAmount); // Reduce the yield by time and penalty.
        ironAmount = penalizeAmount(ironAmount); // Reduce the yield by time and penalty.
    }


}