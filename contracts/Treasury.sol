// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "./KingsGold.sol";


contract Treasury {


    KingsGold public gold;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _gold) {
        gold = KingsGold(_gold);
    }

    // function createProvince() public {
    //     // check that msg.sender is ProvinceManager in a world
    //     // TX.origin is user
    //     // Treasury is allowed to use user's coins

        
        
    //     gold.transferFrom(tx.origin, address(this), provinceCost);



    // }

    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = gold.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        gold.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = gold.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        gold.transferFrom(msg.sender, address(this), amount);
        
        payable(msg.sender).transfer(amount); // Withdrawal pattern is needed

        emit Sold(amount);
    }

}
