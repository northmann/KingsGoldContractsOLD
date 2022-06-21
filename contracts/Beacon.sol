// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "./GenericAccessControl.sol";
import "./Roles.sol";

contract Beacon is Roles, GenericAccessControl {
    address public beaconAddress;

    function setBeacon(address _template) external onlyRole(UPGRADER_ROLE) {
        beaconAddress = _template;
    }
}