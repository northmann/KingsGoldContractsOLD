// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./ResourceFactor.sol";

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

interface IProvince is IAccessControlUpgradeable { 
    function getEvents() external view returns(address[] memory);
    function continent() external view returns(address);
    function getStructure(uint256 _id) external returns(bool, address);
    function setStructure(uint256 _id, address _structureContract) external;
    function setPoppulation(uint256 _manPower, uint256 _attrition) external;
    function payForTime() external;
    function completeEvent() external;
    function completeMint() external;
    function World() external view returns(IWorld);
}

interface IProvinceManager {
    function mintProvince(string memory _name, address _owner) external returns(uint256, IProvince);
}

interface IGenericAccessControl {
    function userManager() external view returns(IUserAccountManager);
}

interface IContinent  { 

    //function continent() external view returns(address);
    //function userManager() external view returns(address);
    function World() external view returns(IWorld);
    function setProvinceManager(IProvinceManager _instance) external;
}

interface IUserAccountManager is IAccessControlUpgradeable { 
    function ensureUserAccount() external returns (IUserAccount);
    function grantProvinceRole(IProvince _province) external;
    function grantTemporaryMinterRole(address _eventContract) external;
    function revokeTemporaryMinterRole(address _eventContract) external; 
    function setEventRole(address _eventContract) external;
    function getUserAccount(address _user) external returns (IUserAccount);
}

interface IUserAccount {
    function provinceCount() external view returns(uint256);
    function addProvince(IProvince _province) external;
    function removeProvince(address _province) external;
    function getProvince(uint256 index) external returns(address);
    function getProvinces() external view returns(address[] memory);
    function setKingdom(address _kingdomAddress) external;
    function setAlliance(address _kingdomAddress) external;
}

interface IStructure  { 
    function Id() external pure returns(uint256);
    function constuctionCost() external view returns(ResourceFactor memory);
    function availableAmount() external view returns(uint256);
    function setAvailableAmount(uint256 _availableAmount) external;
    function addTotalAmount(uint256 _amount) external;
    function removeTotalAmount(uint256 _amount) external;
}


interface IYieldStructure is IStructure { 

    function rewardFactor() external view returns(ResourceFactor memory);
}

interface IStructureManager {
    function Build(address _province, uint256 _structureId, uint256 _count, uint256 _hero) external returns(address);
}

interface IWorld is IGenericAccessControl {
    function food() external view returns(IFood);
    function structureManager () external view returns(IStructureManager);
    function treasury() external view returns(ITreasury);
}

interface IFood is IERC20Upgradeable {
    function mint_with_temp_account(address to, uint256 amount) external;
}

interface ITreasury {
    function Gold() external view returns(IKingsGold);
}

interface IKingsGold is IERC20 {

}