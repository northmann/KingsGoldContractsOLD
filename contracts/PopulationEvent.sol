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

contract PopulationEvent is Initializable, IPopulationEvent, Event {
    uint256 constant POPULATION_EVENT_ID = uint256(keccak256("POPULATION_EVENT"));

    function initialize(IProvince _province, uint256 _rounds, uint256 _manPower, address _hero) initializer public {
        setupEvent(_province);

        _registerInterface(type(IPopulationEvent).interfaceId);

        //multiplier = _multiplier;
        rounds = _rounds;
        manPower = _manPower;
        hero = _hero;

        // Base values before multiplier and rounds
        multiplier = 2e18; // 100% population growth
        penalty = 50e16; // 50%
        attrition = 0;
        timeRequired = 6 hours;
        goldForTime = 1 ether;
        foodAmount = 1 ether; // 1 unit of food for each citizen

        _calculateCost();
    }

    function typeId() public pure override returns(uint256)
    {
        return POPULATION_EVENT_ID;
    }

        /// The cost of the structures in total
    function _calculateCost() internal virtual
    {
        timeRequired = timeRequired * rounds; // Change in manPower could alter this.
        foodAmount = foodAmount * manPower * rounds;
    }


    // function cancel() public override(IEvent, Event) onlyProvince notState(State.Minted) notState(State.Completed) notState(State.Cancelled)
    // {
    //     updatePopulation();

    //     //amountLeft = ((amountLeft * penalty) / 1e18);

    //     //updatePopulation();
    //     state = State.Cancelled;
    // }

    function updatePopulation() internal override
    {
        assert(multiplier >= 1 ether); // multiplier cannot be below 1 ether otherwise there would be negative population growth.

        uint256 populationCreated = (manPower * multiplier) - manPower;
        uint256 reducedAmount = reducedAmountOnTimePassed(populationCreated);
        populationCreated = populationCreated - reducedAmount;
        if(reducedAmount > 0) {
            // Penalty kicks in as time has not yet expire.
            populationCreated = penalizeAmount(populationCreated); // Reduce the created population by the penalty
        }

        province.setPopulationAvailable(province.populationAvailable() + manPower + populationCreated); // return manPower and add new population
        province.setPopulationTotal(province.populationTotal() + populationCreated);
    }


}