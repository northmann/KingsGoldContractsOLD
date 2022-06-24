// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./GenericAccessControl.sol";
import "./KingsGold.sol";
import "./Roles.sol";


contract Treasury is Initializable, Roles, GenericAccessControl, UUPSUpgradeable {


    address public gold;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

   /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _userManager, address _gold) initializer public {
        setUserAccountManager(_userManager);// Has to be set here, before anything else!
        __UUPSUpgradeable_init();
        gold = _gold;
    }


    function setGold(address _gold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        gold = _gold;
    }

    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = KingsGold(gold).balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        KingsGold(gold).transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = KingsGold(gold).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        KingsGold(gold).transferFrom(msg.sender, address(this), amount);
        
        payable(msg.sender).transfer(amount); // Withdrawal pattern is needed

        emit Sold(amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}


}
