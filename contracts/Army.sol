// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";



//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ArmyData.sol";
import "./Interfaces.sol";
//import "./Statics.sol";





contract Army is Initializable, ERC165Storage {

    address public owner;

    uint256 public size;

    address public hero;

    ArmyData data;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() payable {
        _disableInitializers();
    }

    function initialize(address _owner) initializer public {
        owner = _owner;
        //_registerInterface(type(IProvince).interfaceId);

    }

}