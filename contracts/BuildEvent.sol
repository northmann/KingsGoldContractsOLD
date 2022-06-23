// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Event.sol";
//import "./Province.sol";


contract BuildEvent is Initializable, Event {

    address public building;
    uint256 public count;
    uint256 public hero;

    function initialize(address _province, address _building, uint256 _count) initializer public {
        setupEvent(_province);
        building = _building;
        count = _count;

        _calculateCost();
        // manPower = _manPower;
        // hero = _hero;
        // food = _food;
        // wood = _wood;
        // rock = _rock;
        // iron = _iron;
    }

        /// The cost of the buildings in total
    function _calculateCost() internal virtual
    {
    }

}