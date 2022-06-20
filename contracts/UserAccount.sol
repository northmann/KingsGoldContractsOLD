// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";



import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// import "./ArmyData.sol";
// import "./Interfaces.sol";
// import "./Statics.sol";

contract UserAccount is Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private provinces;

    address public kingdom;
    address public alliance;

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() payable {
        _disableInitializers();
    }

    function initialize() initializer public {
        kingdom = tx.origin;
        alliance = tx.origin;
    }

    function provinceCount() public view returns(uint256)
    {
        return provinces.length();
    }

    function addProvince(address _province) public {
        provinces.add(_province);
    }

    function removeProvince(address _province) public {
        provinces.remove(_province);
    }
}
