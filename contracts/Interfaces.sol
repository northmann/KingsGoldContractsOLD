// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./ResourceFactor.sol";
import "./EventSetExtensions.sol";


interface IEvent { 
    function typeId() external pure returns(uint256);
    function province() external view returns(IProvince);
    function world() external view returns(IWorld);
    function multiplier() external returns(uint256);
    function penalty() external returns(uint256);
    function rounds() external returns(uint256);
    function manPower() external returns(uint256);
    function foodAmount() external returns(uint256);
    function woodAmount() external returns(uint256);
    function rockAmount() external returns(uint256);
    function ironAmount() external returns(uint256);

    function priceForTime() external returns(uint256);
    function payForTime() external;
    function paidForTime() external;

    function complete() external;
    function cancel() external;
}

interface IContractType {
    function getType() external pure returns(uint256);
}

interface IProvince is IAccessControlUpgradeable { 
    function latestEvent() external view returns(IEvent);
    function getEvents() external view returns(EventListExtensions.ActionEvent[] memory);
    function continent() external view returns(IContinent);
    function setVassal(address _user) external;
    function removeVassal(address _user) external;

    function populationTotal() external view returns(uint256);
    function populationAvailable() external view returns(uint256);
    function setPopulationTotal(uint256 _count) external;
    function setPopulationAvailable(uint256 _count) external;

    function createStructureEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external;
    function createYieldEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external;
    function createGrowPopulationEvent(uint256 _rounds, uint256 _manPower, uint256 _hero) external returns(IPopulationEvent);
    function getStructure(uint256 _id) external returns(bool, address);
    function setStructure(uint256 _id, IStructure _structureContract) external;
    function payForTime(IEvent _event) external;
    function completeEvent(IEvent _event) external;
    function cancelEvent(IEvent _event) external;
    function world() external view returns(IWorld);
    function containsEvent(IEvent _event) external view returns(bool);
}

interface IProvinceManager {
    
    function setProvinceBeacon(address _template) external;
    function setContinent(IContinent _continent) external;
    function continent() external view returns(IContinent);
    function addSvgResouces(uint256 id, string memory svg) external;
    function mintProvince(string memory _name, address _owner) external returns(uint256, IProvince);
    //function getTokenId(address _provinceAddress) external view returns(uint256);
    function contains(address _provinceAddress) external view returns(bool);
}

interface IGenericAccessControl {
    function userAccountManager() external view returns(IUserAccountManager);
}

interface IContinent  { 

    function world() external view returns(IWorld);
    function createProvince(string memory _name, address owner) external returns(uint256);
    function setProvinceManager(IProvinceManager _instance) external;
    function spendEvent(IEvent _event, address _user) external;
    function payForTime(IEvent _event, address user) external;
    function completeMint(IYieldEvent _event) external;
    // function completeMint(IYieldEvent _yieldEvent) external;
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
    function typeId() external pure returns(uint256);
    function constuctionCost() external view returns(ResourceFactor memory);
    function availableAmount() external view returns(uint256);
    function totalAmount() external view returns(uint256);
    function setAvailableAmount(uint256 _availableAmount) external;
    function setTotalAmount(uint256 _amount) external;
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
    function completeMint() external;
    function penalizeCommodities() external;
}

interface IPopulationEvent is IEvent {
}

interface IEventFactory {
    function ensureStructure(IProvince _province, uint256 _structureId) external returns(IStructure);
    function CreateBuildEvent(IProvince _province, uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external returns(IBuildEvent);
    function CreateYieldEvent(IProvince _province, IYieldStructure _structure, address _receiver, uint256 _multiplier, uint256 _rounds, uint256 _hero) external returns(IYieldEvent);
    function createGrowPopulationEvent(IProvince _province, uint256 _rounds, uint256 _manPower, uint256 _hero) external returns(IPopulationEvent);
    function setStructureBeacon(uint256 _id, address _beaconAddress) external;
    function getStructureBeacon(uint256 _id) external view returns(bool, address);
    function setEventBeacon(uint256 _id, address _beaconAddress) external;
    function getEventBeacon(uint256 _id) external view returns(bool, address);
}

interface IWorld is IGenericAccessControl {
    function baseGoldCost() external view returns(uint256);
    function setBaseGoldCost(uint256 _cost) external;
    function food() external view returns(IFood);
    function wood() external view returns(IWood);
    function rock() external view returns(IRock);
    function iron() external view returns(IIron);
 
    function setFood(IFood _food) external;
    function setWood(IWood _wood) external;
    function setRock(IRock _rock) external;
    function setIron(IIron _iron) external;

    function treasury() external view returns(ITreasury);
    function setTreasury(address _treasuryAddress) external;
    function eventFactory() external view  returns(IEventFactory);
    function setEventFactory(IEventFactory _eventFactory) external;
    function continentsCount() external view returns(uint256);
    function upgradeContinentBeacon(address _beaconAddress) external;
}

interface ICommondity is IERC20Upgradeable {
    function mint_with_temp_account(address to, uint256 amount) external;
}

interface IFood is ICommondity {
}
interface IWood is ICommondity {
}
interface IRock is ICommondity {
}
interface IIron is ICommondity {
}



interface ITreasury {
    function gold() external view returns(IKingsGold);
}

interface IKingsGold is IERC20 {

}