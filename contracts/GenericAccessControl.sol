// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Roles.sol";
import "./Interfaces.sol";
//import "./UserAccountManager.sol";


contract GenericAccessControl is Roles, IGenericAccessControl {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    IUserAccountManager public override userAccountManager;

    modifier onlyRole(bytes32 role) {
        require(userAccountManager.hasRole(role, msg.sender),"GenericAccessControl.onlyRole : Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(userAccountManager.hasRole(role1, msg.sender) || userAccountManager.hasRole(role2, msg.sender),"GenericAccessControl.onlyRoles : Access denied");
        _;
    }

    function setUserAccountManager(IUserAccountManager _userAccountManager) public onlyRole(DEFAULT_ADMIN_ROLE) { 
        __setUserAccountManager(_userAccountManager);
    }

    function __setUserAccountManager(IUserAccountManager _userAccountManager) internal {
        userAccountManager =_userAccountManager;
    }

    // function userAccountManager() public view override returns(IUserAccountManager) {
    //     return userAccountManager;
    // }


    // modifier ownerOrVassel() {
    //     require(hasRole(OWNER_ROLE, msg.sender) || hasRole(VASSAL_ROLE, msg.sender),"Access denied");
    //     _;
    // }


}