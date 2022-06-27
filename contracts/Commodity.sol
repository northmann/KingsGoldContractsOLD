// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./GenericAccessControl.sol";
import "./Roles.sol";
import "./Interfaces.sol";


// Minimal change-----
// Roles added
// GenericAccessControl added
contract Commodity is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, Roles, GenericAccessControl, UUPSUpgradeable, ICommondity {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IUserAccountManager _userAccountManager) initializer virtual public {
        __setUserAccountManager(_userAccountManager);// Has to be set here, before anything else!
        __ERC20_init("KingsGold Commodity", "KSGC");
        __ERC20Burnable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
    }

    function mint_with_temp_account(address to, uint256 amount) public override onlyRole(TEMPORARY_MINTER_ROLE) {
        _mint(to, amount);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}