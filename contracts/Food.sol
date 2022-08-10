// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Commodity.sol";


contract Food is Initializable, Commodity, IFood {

    function initialize(IUserAccountManager _userAccountManager, ITreasury _treasury) initializer override public {
        super.initialize(_userAccountManager, _treasury);
        __ERC20_init("KingsGold Food", "KSGF");
    }
}
