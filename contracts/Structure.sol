// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Province.sol";
import "./Roles.sol";
import "./BuildFactor.sol";


contract Structure is Initializable, Roles {

    address public province;

    BuildFactor public cost;

    uint256 public amount;

    modifier onlyRole(bytes32 role) {
        require(Province(province).hasRole(role, msg.sender),"Access denied");
        _;
    }
    

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(Province(province).hasRole(role1, msg.sender) || Province(province).hasRole(role2, msg.sender),"Access denied");
        _;
    }

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        _init();
    }

    function _init() internal virtual 
    {
    }


    function Id() public pure virtual returns(uint256)
    {
        return 0;
    }

    function addAmount(uint256 _count) public onlyRole(EVENT_ROLE) {
        amount += _count;
    }

    // function Build(uint256 manPower, uint256 _hero, uint256 food, uint256 wood, uint256 rock, uint256 iron) external virtual {

    // }



    function getSvg() public view virtual returns (string memory) {
        return string(abi.encodePacked(""));
    }    

}