// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Event.sol";
import "./Structure.sol";
import "./BuildFactor.sol";

contract BuildEvent is Initializable, Event {

    address public structure;
    uint256 public count;

    function initialize(address _province, address _structure, uint256 _count, address _hero) initializer public {
        setupEvent(_province);
        structure = _structure;
        count = _count;
        hero = _hero;

        _calculateCost();
    }

        /// The cost of the structures in total
    function _calculateCost() internal virtual
    {
        (uint256 manPowerFactor,
        uint256 attritionFactor,
        uint256 timeFactor,
        uint256 goldForTimeFactor,
        uint256 foodFactor,
        uint256 woodFactor,
        uint256 rockFactor,
        uint256 ironFactor) = Structure(structure).cost();

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
        Structure(structure).addAmount(count);
        
        Province(province).setStructure(Structure(structure).Id(), structure);
        Province(province).setPoppulation(manPower, 0);
        Province(province).completeEvent();

        // Kill the contract??
    }

}