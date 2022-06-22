// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./OpenZeppelinFood.sol";


contract Food is OpenZeppelinFood {


    function mint_with_temp_account(address to, uint256 amount) public onlyRole(TEMPORARY_MINTER_ROLE) {
        _mint(to, amount);
    }
}
