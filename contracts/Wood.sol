// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Commodity.sol";


contract Wood is Initializable, Commodity, IFood {

    function initialize(IUserAccountManager _userAccountManager) initializer override public {
        super.initialize(_userAccountManager);
        __ERC20_init("KingsGold Wood", "KSGW");
    }
}
