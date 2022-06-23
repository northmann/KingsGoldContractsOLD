// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Building.sol";
import "./BuildingManager.sol";
import "./Roles.sol";


contract Farm is Building  {

    function Id() public pure override returns(uint256)
    {
        return FARM_BUILDING_ID;
    }

    // function Build(uint256 manPower, uint256 _hero, uint256 food, uint256 wood, uint256 rock, uint256 iron) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE) {
    //     // Check access to province
    //     // Get existing building is exist
    //     // Create an event

    // }

    function getSvg() public view override returns (string memory) {
        return string(abi.encodePacked(""));
    }    
}