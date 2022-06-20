// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;


contract Roles {
    //bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant VASSAL_ROLE = keccak256("VASSAL_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    
}