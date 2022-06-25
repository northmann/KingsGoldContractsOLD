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

contract YieldEvent is Initializable, Event {

    address public structure;
    uint256 public count;
    address public receiver;

    function initialize(address _province, address _structure, address _receiver, uint256 _count, address _hero) initializer public {
        setupEvent(_province);
        structure = _structure;
        receiver = _receiver;
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
        // uint256 ironFactor) = IYieldStructure(structure).rewardFactor();
        ResourceFactor memory factor = IYieldStructure(structure).rewardFactor();
                                                   

        manPower = count * factor.manPower; // The cost in manPower
        attrition = factor.attrition;
        timeRequired = factor.time; // Change in manPower could alter this.
        goldForTime = count * factor.goldForTime;
        foodAmount = count * factor.food;
        woodAmount = count * factor.wood;
        rockAmount = count * factor.rock;
        ironAmount = count * factor.iron;
    }


        /// The cost of the time to complete the event.
    function priceForTime() external view override returns(uint256)
    {
        return goldForTime;
    }

    function completeEvent() public override onlyRoles(OWNER_ROLE, VASSAL_ROLE) timeExpired
    {
        // Return manPower to population pool
        IProvince(province).setPoppulation(manPower, 0);

        // Payout the reward
        IProvince(province).completeMint();
       
        IProvince(province).completeEvent();

        super.completeEvent();
        // Kill the contract??
    }

    function completeMint() public override virtual timeExpired onlyMinter
    {
        // Reward the user with commodities
        if(foodAmount > 0) {
            world.food().mint_with_temp_account(receiver,foodAmount);
        }
    }

}