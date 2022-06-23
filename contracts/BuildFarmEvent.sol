// // SPDX-License-Identifier: MIT
// // solhint-disable-next-line
// pragma solidity >0.8.2;
// import "hardhat/console.sol";

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// import "./BuildEvent.sol";
// import "./Province.sol";

// //Initializable
// contract BuildFarmEvent is Initializable, BuildEvent {

//     // // function initialize(address _provinceAddress, address _hero, uint256 _populationUsed, uint256 _provinceFarmYieldFactor, uint256 _attritionFactor) initializer public {
//     // //     setupEvent(_provinceAddress);

//     // //     hero = _hero;
//     // //     populationUsed = _populationUsed;
//     // //     timeRequired = 24 hours; // Number of blocks
//     // //     goldForTimeFactor = 1 ether; // something in wei, the factor price should reflect that its cheaper to farm than to buy on open market.
//     // //     yieldFactor = _provinceFarmYieldFactor;
//     // //     attritionFactor = _attritionFactor; // 100% = 18*0 = 1 eth. _attritionFactor cannot be more than 1 eth.
//     // // }

//     // // The cost of the buildings in total
//     // function _calculateCost() internal override virtual
//     // {
//     //     // A hero can influence the affect of factors.
//     //     //manPower = 

//     // }

//     // /// The cost of the time to complete the event.
//     // function priceForTime() external view override returns(uint256)
//     // {
//     //     return goldForTime;
//     // }

//     // function completeEvent() public override onlyRoles(OWNER_ROLE, VASSAL_ROLE) timeExpired
//     // {
//     //     // calc the result
//     //     // use the hero farm skill
//     //     //Province provinceInstance = Province(province);


//     //     // uint256 populationRest = (populationUsed - ((populationUsed * attritionFactor) / 1 ether));
//     //     // populationSurvived = populationUsed - populationRest;
//     // }

// }