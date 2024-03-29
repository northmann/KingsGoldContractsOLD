// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./GenericAccessControl.sol";
import "./Interfaces.sol";
import "./Roles.sol";


contract Treasury is Initializable, Roles, GenericAccessControl, UUPSUpgradeable, ReentrancyGuardUpgradeable, ITreasury {


    IKingsGold public override gold;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

   /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IUserAccountManager _userAccountManager, address _gold) initializer public {
        __setUserAccountManager(_userAccountManager);// Has to be set here, before anything else!
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        gold = IKingsGold(_gold);
    }

    function setGold(address _gold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        gold = IKingsGold(_gold);
    }

    function buy() payable public override nonReentrant {
        uint256 amountTobuy = msg.value;
        require(amountTobuy > 0, "You need to send some ether");
        uint256 dexBalance = gold.balanceOf(address(this));
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        
        gold.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public override nonReentrant {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = gold.allowance(msg.sender, address(this));
        require(allowance >= amount, "Not enough token allowance");
        gold.transferFrom(msg.sender, address(this), amount);
        
        payable(msg.sender).transfer(amount); // Withdrawal pattern is needed

        emit Sold(amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}


}
