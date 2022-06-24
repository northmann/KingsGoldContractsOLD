// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import "./Statics.sol"; Only ProvinceID
import "./BuildEvent.sol";
//import "./YieldEvent.sol";
import "./Interfaces.sol";
import "./Continent.sol";
import "./Roles.sol";
import "./StructureManager.sol";
import "./Structure.sol";
import "./EventSetExtensions.sol";




//, Roles, 
contract Province is Initializable, Roles, AccessControlUpgradeable, IProvince {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EventSetExtensions for EnumerableSet.AddressSet;

    address private continentAddress;

    string public name;

    address public owner;
    address public vassal;

    uint32 public positionX;
    uint32 public positionY;

    uint32 public plains;   // Food
    uint32 public forest;   // Wood
    uint32 public mountain; // Stone
    uint32 public hills;    // Gold and iron ore

    uint256 public populationTotal;
    uint256 public populationAvailable;
    address public armyContract;

    EnumerableSet.AddressSet private events;

    EnumerableMap.UintToAddressMap private structures;

    EnumerableSet.AddressSet private incomingTransfers;
    EnumerableSet.AddressSet private insideTransfers;
    EnumerableSet.AddressSet private outgoingTransfers;


    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(hasRole(role1, msg.sender) || hasRole(role2, msg.sender),"Access denied");
        _;
    }

    modifier onlyEvent() {
        require(events.contains(msg.sender)); //Event must be listed on the province's events.
        _;
    }

    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, address _owner, address _continent) initializer public {
        __AccessControl_init();
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(MINTER_ROLE, _continent);
        continentAddress = _continent;
        name = _name;
    }

    function continent() public view override returns(address)
    {
        return continentAddress;
    }

    function setVassal(address _user) external onlyRole(OWNER_ROLE)
    {
        _setupRole(VASSAL_ROLE, _user);
    }

    function createStructure(uint256 _structureId, uint256 _count, uint256 _hero) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        
        // Create a new Build event        
        address eventAddress = StructureManager(Continent(continentAddress).structureManager()).Build(address(this), _structureId, _count, _hero);
        BuildEvent buildEvent = BuildEvent(eventAddress);

        // Check that there is mamPower enough to build the requested structures.
        require(buildEvent.manPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - buildEvent.manPower();

        // Spend the resouces on the behalf of the user
        Continent(continentAddress).spendEvent(eventAddress); 
        
        // Add the event to the list of activities on the province.
        events.add(eventAddress); // Needs some refactoring, as we do not know the type of event !
        
        _grantRole(EVENT_ROLE, eventAddress); // Enable the event to perform actions on this provice.
    }

//     function createYieldEvent(uint256 _structureId, uint256 _count, uint256 _hero) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
//         // check that the hero exist and is controlled by user.
//         //IProvince provinceInstance = IProvince(msg.sender)

// //        (bool structureExist, address structureAddress) = provinceInstance.getStructure(_structureId);
// //        require(structureExist,"Structure do not exist");
        
//         // Create a new Build event        
//         address eventAddress = StructureManager(Continent(continentAddress).structureManager()).CreateYieldEvent(address(this), _structureId, msg.sender, _count, _hero);
//         YieldEvent yieldEvent = YieldEvent(eventAddress);

//         // Check that there is mamPower enough to build the requested structures.
//         require(yieldEvent.manPower() <= populationAvailable, "not enough population");
//         populationAvailable = populationAvailable - yieldEvent.manPower();

//         Structure structure = Structure(structureAddress);
//         require(structure.availableAmount < _count, "Insufficient structures");

//         structure.setAvailableAmount(structure.availableAmount() - _count);

//         // Add the event to the list of activities on the province.
//         events.add(eventAddress); // Needs some refactoring, as we do not know the type of event !
        
//         _grantRole(EVENT_ROLE, eventAddress); // Enable the event to perform actions on this provice.
//     }



    function getStructure(uint256 _id) public view override returns(bool, address) {
        return structures.tryGet(_id);
    }

    function getEvents() public view override returns(address[] memory)  {
        return events.getEvents();
    }

    function setStructure(uint256 _id, address _structureContract) public override onlyRole(EVENT_ROLE) onlyEvent {
        structures.set(_id, _structureContract);
    }

    function setPoppulation(uint256 _manPower, uint256 _attrition) public override onlyRole(EVENT_ROLE) onlyEvent {
        populationAvailable += _manPower; // Return the manPower to the available pool. Attrition is included in manPower.
        populationTotal -= _attrition; // Remove some of the population because of attrition.
    }

    function payForTime() public override  onlyRole(EVENT_ROLE) onlyEvent
    {
        Continent(continentAddress).payForTime(msg.sender);
    }

    function completeEvent() public override  onlyRole(EVENT_ROLE) onlyEvent
    {
        // Province calls continent on behalf of Event.
        events.remove(msg.sender);
    }


    function completeMint() public override onlyRole(EVENT_ROLE) onlyEvent
    {
        // Province calls continent on behalf of Event.
        Continent(continentAddress).completeMint(msg.sender);
    }
}