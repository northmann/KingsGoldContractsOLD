// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./UserAccount.sol";
import "./Roles.sol";

contract UserAccountManager is Initializable, Roles, AccessControlUpgradeable, UUPSUpgradeable {

    address public userAccountBeacon;
    mapping(address => address) private users;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _userAccountBeacon) initializer public virtual {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, tx.origin);

        userAccountBeacon = _userAccountBeacon;
    }

    // /**
    //  * @dev Returns `true` if `account` has been granted `role`.
    //  */
    // function hasRole(bytes32 role, address account) public view override returns (bool) {
    //     return super.hasRole(role, account);
    // }
    
    function ensureUserAccount() public onlyRole(MINTER_ROLE) returns(address) {
        if(users[tx.origin] != address(0)) return users[tx.origin]; // If user exist, then just return.

        BeaconProxy proxy = new BeaconProxy(userAccountBeacon,abi.encodeWithSelector(UserAccount(address(0)).initialize.selector));
        users[tx.origin] = address(proxy);
        return address(proxy);
    }

    function getUserAccount(address _user) external view returns(address) {
        return users[_user];
    }

    /// Upgrade the UserAccount template
    function upgradeUserAccountBeacon(address _beaconAddress) external onlyRole(UPGRADER_ROLE) {
        userAccountBeacon = _beaconAddress;
    }

    /// Upgrade the UserAccountManager template
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
