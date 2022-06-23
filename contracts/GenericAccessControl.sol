// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Roles.sol";
import "./UserAccountManager.sol";


contract GenericAccessControl is Initializable, Roles {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public userManager;

    modifier onlyRole(bytes32 role) {
        require(UserAccountManager(userManager).hasRole(role, msg.sender),"Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(UserAccountManager(userManager).hasRole(role1, msg.sender) || UserAccountManager(userManager).hasRole(role2, msg.sender),"Access denied");
        _;
    }

    function setUserAccountManager(address _userManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        userManager =_userManager;
    }



    // modifier ownerOrVassel() {
    //     require(hasRole(OWNER_ROLE, msg.sender) || hasRole(VASSAL_ROLE, msg.sender),"Access denied");
    //     _;
    // }


}