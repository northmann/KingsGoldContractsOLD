// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./OpenZeppelinFood.sol";


contract Food is OpenZeppelinFood, IFood {

    function mint_with_temp_account(address to, uint256 amount) public override onlyRole(TEMPORARY_MINTER_ROLE) {
        _mint(to, amount);
    }
}
