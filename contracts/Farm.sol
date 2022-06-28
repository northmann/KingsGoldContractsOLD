// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";


import "./YieldStructure.sol";
import "./ResourceFactor.sol";

uint256 constant FARM_STRUCTURE_ID = uint256(keccak256("FARM_STRUCTURE"));


contract Farm is YieldStructure  {


    function _init() internal override {
        costFactor = ResourceFactor({
                    manPower:10,
                    attrition: 2e16, // 2 % base = 1 ether
                    time:4 hours,
                    goldForTime: 0.1 ether,
                    food:0,
                    wood:100,
                    rock:0,
                    iron:0
        });

        yieldRewardFactor = ResourceFactor({
            manPower: 10,
            attrition: 2e16, // 2 %
            time: 4 hours,
            goldForTime: 0.1 ether,
            food:100,
            wood:0,
            rock:0,
            iron:0
        });

    }


    function typeId() public pure override returns(uint256) {
        return FARM_STRUCTURE_ID;
    }

    function getSvg() public pure override returns (string memory) {
        return string(abi.encodePacked(""));
    }    
}