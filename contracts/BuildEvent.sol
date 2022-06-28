// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Event.sol";
import "./ResourceFactor.sol";
import "./Interfaces.sol";

contract BuildEvent is Initializable, Event, IBuildEvent {
    uint256 constant BUILD_EVENT_ID = uint256(keccak256("BUILD_EVENT"));

    IStructure public override structure;
    uint256 public count;

    function initialize(IProvince _province, IStructure _structure, uint256 _count, address _hero) initializer public {
        setupEvent(_province);
        structure = _structure;
        count = _count;
        hero = _hero;

        _calculateCost();
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
        // uint256 ironFactor) = IStructure(structure).constuctionCost();
        ResourceFactor memory factor = structure.constuctionCost();

        manPower = count * factor.manPower;
        attrition = factor.attrition;
        timeRequired = factor.time; // Change in manPower could alter this.
        goldForTime = count * factor.goldForTime;
        foodAmount = count * factor.food;
        woodAmount = count * factor.wood;
        rockAmount = count * factor.rock;
        ironAmount = count * factor.iron;
    }

    function typeId() public pure override returns(uint256)
    {
        return BUILD_EVENT_ID;
    }


    function completeEvent() public override(Event, IEvent) onlyMinter timeExpired notState(State.Completed)
    {

        IStructure structureInstance = IStructure(structure);
        structureInstance.setAvailableAmount(structureInstance.availableAmount() + count);
        structureInstance.addTotalAmount(count);
        
        province.setStructure(structure.typeId(), structure);

        //province.setPoppulation(manPower, 0);
        //province.completeEvent();

        super.completeEvent();
        // Kill the contract??
    }

}