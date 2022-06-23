// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Event.sol";
import "./Building.sol";
import "./BuildFactor.sol";

contract BuildEvent is Initializable, Event {

    address public building;
    uint256 public count;

    function initialize(address _province, address _building, uint256 _count, address _hero) initializer public {
        setupEvent(_province);
        building = _building;
        count = _count;
        hero = _hero;

        _calculateCost();
    }

        /// The cost of the buildings in total
    function _calculateCost() internal virtual
    {
        (uint256 manPowerFactor,
        uint256 attritionFactor,
        uint256 timeFactor,
        uint256 goldForTimeFactor,
        uint256 foodFactor,
        uint256 woodFactor,
        uint256 rockFactor,
        uint256 ironFactor) = Building(building).cost();

        manPower = count * manPowerFactor;
        attrition = attritionFactor;
        timeRequired = count * timeFactor;
        goldForTime = count * goldForTimeFactor;
        food = count * foodFactor;
        wood = count * woodFactor;
        rock = count * rockFactor;
        iron = count * ironFactor;
    }


        /// The cost of the time to complete the event.
    function priceForTime() external view override returns(uint256)
    {
        return goldForTime;
    }

    function completeEvent() public override onlyRoles(OWNER_ROLE, VASSAL_ROLE) timeExpired
    {
        Building(building).addAmount(count);
        
        Province(province).setBuilding(Building(building).Id(), building);
        Province(province).setPoppulation(manPower, 0);
        Province(province).completeEvent();

        // Kill the contract??
    }

}