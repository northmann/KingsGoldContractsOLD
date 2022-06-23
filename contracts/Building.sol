// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


import "./Province.sol";

contract Building is Initializable {

    address public province;

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        // __AccessControl_init();
        // _grantRole(OWNER_ROLE, _owner);
        // _grantRole(MINTER_ROLE, _continent);
        // continent = _continent;
        // name = _name;
    }


    modifier onlyRole(bytes32 role) {
        require(Province(province).hasRole(role, msg.sender),"Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(Province(province).hasRole(role1, msg.sender) || Province(province).hasRole(role2, msg.sender),"Access denied");
        _;
    }


    function Id() public pure virtual returns(uint256)
    {
        return 0;
    }

    function Build(uint256 manPower, uint256 _hero, uint256 food, uint256 wood, uint256 rock, uint256 iron) external virtual {

    }

    function getSvg() public view virtual returns (string memory) {
        return string(abi.encodePacked(""));
    }    

}