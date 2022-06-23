// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library EventSetExtensions {
    using EnumerableSet for EnumerableSet.AddressSet;

    function getEvents(EnumerableSet.AddressSet storage events) internal view returns(address[] memory) {
        address[] memory result = new address[](events.length());
        for(uint256 i = 0; i < events.length(); i++)
            result[i] = events.at(i);
        return result;
    }
}