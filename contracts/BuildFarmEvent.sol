// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BuildEvent.sol";
import "./Province.sol";

//Initializable
contract BuildFarmEvent is Initializable, BuildEvent {

    // uint256 public populationUsed;
    // uint256 public populationSurvived;
    // uint256 public populationIncrease;
 
    // uint256 public yieldFactor;

    // uint256 public attritionFactor;

    //address public hero;

    // function initialize(address _provinceAddress, address _hero, uint256 _populationUsed, uint256 _provinceFarmYieldFactor, uint256 _attritionFactor) initializer public {
    //     setupEvent(_provinceAddress);

    //     hero = _hero;
    //     populationUsed = _populationUsed;
    //     timeRequired = 24 hours; // Number of blocks
    //     goldForTimeFactor = 1 ether; // something in wei, the factor price should reflect that its cheaper to farm than to buy on open market.
    //     yieldFactor = _provinceFarmYieldFactor;
    //     attritionFactor = _attritionFactor; // 100% = 18*0 = 1 eth. _attritionFactor cannot be more than 1 eth.
    // }

    // /// The cost of the time to complete the event.
    // function priceForTime() external view override returns(uint256)
    // {
    //     return populationUsed * timeRequired * goldForTimeFactor;
    // }

    // function completeEvent() public override onlyRoles(OWNER_ROLE, VASSAL_ROLE) timeExpired
    // {
    //     // calc the result
    //     // use the hero farm skill
    //     //Province provinceInstance = Province(province);

    //     uint256 populationRest = (populationUsed - ((populationUsed * attritionFactor) / 1 ether));
    //     populationSurvived = populationUsed - populationRest;
    // }

}