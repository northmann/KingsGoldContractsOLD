// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.4;
//pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./GenericAccessControl.sol";
import "./Roles.sol";


/// @title KSGMulticall
/// @author Northmann

contract KSGMulticall is ReentrancyGuard, Roles, GenericAccessControl {

    event Callresult(address target, bool success, bytes result);

    struct Call {
        address target;
        bytes callData;
    }

    // @author Northmann
    // @dev Executes a series of function calls that can change state. 
    // @param _calls The calls to be executed.
    function callFunctions(Call[] calldata calls) external payable nonReentrant onlyRole(USER_ROLE) {
        // Make sure that a evil contract cannot call behalf of the origin caller.
        require(msg.sender == tx.origin, "callFunctions can only be called directly and not by a proxy");

        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call{ value: msg.value }(calls[i].callData);
            require(success, "Multicall aggregate: call failed");
            emit Callresult(calls[i].target, success, ret);
        }
    }
}