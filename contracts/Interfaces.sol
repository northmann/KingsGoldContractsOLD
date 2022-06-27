// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./ResourceFactor.sol";

interface IEvent { 
    function Id() external pure returns(uint256);
    function province() external view returns(IProvince);
    function world() external view returns(IWorld);
    function ManPower() external returns(uint256);
    function FoodAmount() external returns(uint256);
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
    function continent() external view returns(IContinent);
    function createStructure(uint256 _structureId, uint256 _count, uint256 _hero) external;
    function getStructure(uint256 _id) external returns(bool, address);
    function setStructure(uint256 _id, IStructure _structureContract) external;
    function setPoppulation(uint256 _manPower, uint256 _attrition) external;
    function payForTime() external;
    function completeEvent() external;
    function completeMint() external;
    function world() external view returns(IWorld);
}

interface IProvinceManager {
    function setContinent(IContinent _continent) external;
    function continent() external view returns(IContinent);
    function addSvgResouces(uint256 id, string memory svg) external;
    function mintProvince(string memory _name, address _owner) external returns(uint256, IProvince);
}

interface IGenericAccessControl {
    function userAccountManager() external view returns(IUserAccountManager);
}

interface IContinent  { 

    function world() external view returns(IWorld);
    function createProvince(string memory _name, address owner) external returns(uint256);
    function setProvinceManager(IProvinceManager _instance) external;
    function spendEvent(IEvent _eventContract) external;
    function payForTime(address _contract) external;
    function completeMint(address _eventContract) external;
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
    function province() external view returns(IProvince);
    function Id() external pure returns(uint256);
    function constuctionCost() external view returns(ResourceFactor memory);
    function availableAmount() external view returns(uint256);
    function setAvailableAmount(uint256 _availableAmount) external;
    function addTotalAmount(uint256 _amount) external;
    function removeTotalAmount(uint256 _amount) external;
}


interface IYieldStructure is IStructure { 
    //function structure() external view returns(IYieldStructure);
    function rewardFactor() external view returns(ResourceFactor memory);
}

interface IBuildEvent is IEvent {
    function structure() external view returns(IStructure);
}


interface IYieldEvent is IEvent {
    function structure() external view returns(IYieldStructure);
}


interface IEventFactory {
    //function continent() external view returns(IContinent);
    function CreateBuildEvent(IProvince _province, uint256 _structureId, uint256 _count, uint256 _hero) external returns(IBuildEvent);
    function CreateYieldEvent(IProvince _province, IYieldStructure _structure, address _receiver, uint256 _count, uint256 _hero) external returns(IYieldEvent);
    //function setContinent(IContinent _continent) external;
    function setStructureBeacon(uint256 _id, address _beaconAddress) external;
    function getStructureBeacon(uint256 _id) external view returns(bool, address);
    function setEventBeacon(uint256 _id, address _beaconAddress) external;
    function getEventBeacon(uint256 _id) external view returns(bool, address);
}

interface IWorld is IGenericAccessControl {
    function food() external view returns(IFood);
    function treasury() external view returns(ITreasury);
    function eventFactory() external view  returns(IEventFactory);
    function setEventFactory(IEventFactory _eventFactory) external;
    function continentsCount() external view returns(uint256);
}

interface ICommondity is IERC20Upgradeable {
    function mint_with_temp_account(address to, uint256 amount) external;
}

interface IFood is ICommondity {
}

interface ITreasury {
    function gold() external view returns(IKingsGold);
}

interface IKingsGold is IERC20 {

}