// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

library EventMapExtensions {
}


library EventListExtensions {
    struct ActionEvent{
        address instance;
        uint256 typeId;
    }


    struct Page {
        ActionEvent[] list;
        uint256 count;
    }

    struct History {
        Page[] pages;
    }

    using EnumerableMap for EnumerableMap.AddressToUintMap;

    function getEvents(EnumerableMap.AddressToUintMap storage events) internal view returns(ActionEvent[] memory) {
        ActionEvent[] memory result = new ActionEvent[](events.length());
        for(uint256 i = 0; i < events.length(); i++) {
            (address addr, uint256 typeId) =events.at(i);
            result[i] = ActionEvent(addr, typeId);
        }
        return result;
    }


    function add(EventListExtensions.History storage eventHistory, address _instance, uint256 typeId) internal  {
        // EventListExtensions.Page storage currentPage = eventHistory.pages[eventHistory.pages.length];
        // if(currentPage.count > 100) {
        //     ActionEvent[] memory arr;
        //     // EventListExtensions.Page memory page = ;
        //     // page.list.push(ActionEvent(_instance, typeId));
        //     eventHistory.pages.push(Page(arr, 0));
        //     currentPage = eventHistory.pages[eventHistory.pages.length];
        // } 
        // currentPage.list.push(ActionEvent(_instance, typeId));
    }

    function getActionEvents(EventListExtensions.History storage eventHistory, uint256 _pageIndex) internal view returns (ActionEvent[] memory) {
        Page memory page = eventHistory.pages[_pageIndex];
        ActionEvent[] memory store = page.list;
        ActionEvent[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

}
