// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Structure.sol";
import "./ResourceFactor.sol";



contract YieldStructure is Structure, IYieldStructure  {

    // The factor setup for how much yield reward is give or farming, mining, etc.
    ResourceFactor internal yieldRewardFactor;

    function rewardFactor() public view override returns(ResourceFactor memory)
    {
        return yieldRewardFactor;
    }

    function makeYield(uint256 _count) public virtual {
        
    }    
}