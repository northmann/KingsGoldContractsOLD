// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "./UserAccount.sol";
import "./Roles.sol";
import "./Interfaces.sol";

contract UserAccountManager is
    Initializable,
    Roles,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    address public userAccountBeacon;
    mapping(address => address) private users;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _userAccountBeacon) public virtual initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _grantRole(MINTER_ROLE, tx.origin);
        _grantRole(UPGRADER_ROLE, tx.origin);

        userAccountBeacon = _userAccountBeacon;
    }

    // /**
    //  * @dev Returns `true` if `account` has been granted `role`.
    //  */
    // function hasRole(bytes32 role, address account) public view override returns (bool) {
    //     return super.hasRole(role, account);
    // }

    function ensureUserAccount()
        public
        onlyRole(MINTER_ROLE)
        returns (address)
    {
        if (users[tx.origin] != address(0)) return users[tx.origin]; // If user exist, then just return.

        BeaconProxy proxy = new BeaconProxy(
            userAccountBeacon,
            abi.encodeWithSelector(UserAccount(address(0)).initialize.selector)
        );
        users[tx.origin] = address(proxy);

        _grantRole(USER_ROLE, tx.origin);

        return address(proxy);
    }

    function grantProvinceRole(address _province) public onlyRole(MINTER_ROLE) {
        _grantRole(PROVINCE_ROLE, _province);
    }

    function grantTemporaryMinterRole(address _eventContract) public onlyRole(MINTER_ROLE) {
        _grantRole(TEMPORARY_MINTER_ROLE, _eventContract);
    }

    function revokeTemporaryMinterRole(address _eventContract) public onlyRole(MINTER_ROLE) {
        _revokeRole(TEMPORARY_MINTER_ROLE, _eventContract);
    }

    // Can only be called by a Province Contract
    function setEventRole(address _eventContract) public onlyRole(PROVINCE_ROLE) {
        require(ERC165Checker.supportsInterface(_eventContract, type(IEvent).interfaceId), "Not a event contract");

        _grantRole(EVENT_ROLE, _eventContract);
    }

    function getUserAccount(address _user) external view returns (address) {
        return users[_user];
    }

    /// Upgrade the UserAccount template
    function upgradeUserAccountBeacon(address _template)
        external
        onlyRole(UPGRADER_ROLE)
    {
        userAccountBeacon = _template;
    }

    /// Upgrade the UserAccountManager template
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
