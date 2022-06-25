// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "./Roles.sol";
import "./Interfaces.sol";
//import "./UserAccountManager.sol";


contract GenericAccessControl is Roles {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address internal userManagerAddress;

    modifier onlyRole(bytes32 role) {
        require(IUserAccountManager(userManagerAddress).hasRole(role, msg.sender),"Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(IUserAccountManager(userManagerAddress).hasRole(role1, msg.sender) || IUserAccountManager(userManagerAddress).hasRole(role2, msg.sender),"Access denied");
        _;
    }

    function setUserAccountManager(address _userManager) public onlyRole(DEFAULT_ADMIN_ROLE) { 
        __setUserAccountManager(_userManager);
    }

    function __setUserAccountManager(address _userManager) internal {
        userManagerAddress =_userManager;
    }

    function userManager() public view returns(IUserAccountManager) {
        return IUserAccountManager(userManagerAddress);
    }


    // modifier ownerOrVassel() {
    //     require(hasRole(OWNER_ROLE, msg.sender) || hasRole(VASSAL_ROLE, msg.sender),"Access denied");
    //     _;
    // }


}