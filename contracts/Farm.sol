// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Building.sol";
import "./BuildingManager.sol";
import "./Roles.sol";
import "./BuildFactor.sol";



contract Farm is Building  {


    function _init() internal override {
        cost = BuildFactor({
                    manPower:10,
                    attrition:1000,
                    time:4 hours,
                    goldForTime: 0.1 ether,
                    food:0,
                    wood:100,
                    rock:0,
                    iron:0
        });
    }


    function Id() public pure override returns(uint256) {
        return FARM_BUILDING_ID;
    }

    function getSvg() public pure override returns (string memory) {
        return string(abi.encodePacked(""));
    }    
}