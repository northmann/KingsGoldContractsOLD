// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

interface IEvent { 
    function completeEvent() external;
    function completeMint() external;
}

interface ITimeContract is IEvent {   

    function priceForTime() external returns(uint256);
    function payForTime() external;
    function paidForTime() external;
}

interface IContractType {
    function getType() external pure returns(uint256);
}

interface IProvince { }
