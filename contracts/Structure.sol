// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Province.sol";
import "./Roles.sol";
import "./ResourceFactor.sol";
import "./Interfaces.sol";


contract Structure is Initializable, Roles, IStructure {

    address public province;

    ResourceFactor internal costFactor;

    uint256 internal _availableAmount;
    uint256 public totalAmount;

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


    function Id() public pure override virtual returns(uint256)
    {
        return 0;
    }

    function constuctionCost() public view override returns(ResourceFactor memory)
    {
        return costFactor;
    }

    function availableAmount() public view override returns(uint256)
    {
        return _availableAmount;
    }


    function setAvailableAmount(uint256 _availableAmount) public override onlyRoles(PROVINCE_ROLE,EVENT_ROLE) {
        _availableAmount = _availableAmount;
    }

    function addTotalAmount(uint256 _amount) public override onlyRoles(PROVINCE_ROLE,EVENT_ROLE) {
        totalAmount += _amount;
    }

    function removeTotalAmount(uint256 _amount) public override onlyRoles(PROVINCE_ROLE,EVENT_ROLE) {
        totalAmount -= _amount;
    }


    // function Build(uint256 manPower, uint256 _hero, uint256 food, uint256 wood, uint256 rock, uint256 iron) external virtual {

    // }



    function getSvg() public view virtual returns (string memory) {
        return string(abi.encodePacked(""));
    }    

}