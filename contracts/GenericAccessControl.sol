// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "./Roles.sol";
import "./UserAccountManager.sol";


contract GenericAccessControl is Initializable, Roles {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    UserAccountManager public userManager;

    modifier onlyRole(bytes32 role) {
        require(userManager.hasRole(role, msg.sender),"Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(userManager.hasRole(role1, msg.sender) || userManager.hasRole(role2, msg.sender),"Access denied");
        _;
    }


    function setUserAccountManager(address _userManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        userManager = UserAccountManager(_userManager);
    }

    // modifier ownerOrVassel() {
    //     require(hasRole(OWNER_ROLE, msg.sender) || hasRole(VASSAL_ROLE, msg.sender),"Access denied");
    //     _;
    // }


}