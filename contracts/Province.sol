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
import "./Interfaces.sol";
import "./Continent.sol";
import "./Roles.sol";
import "./StructureManager.sol";
import "./Structure.sol";
import "./EventSetExtensions.sol";



//, Roles, 
contract Province is Initializable, Roles, AccessControlUpgradeable {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EventSetExtensions for EnumerableSet.AddressSet;

    address public continent;

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
        continent = _continent;
        name = _name;
    }

    function setVassal(address _user) external onlyRole(OWNER_ROLE)
    {
        _setupRole(VASSAL_ROLE, _user);
    }

    function createStructure(uint256 _structureId, uint256 _count, uint256 _hero) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        
        // Create a new Build event        
        address eventAddress = StructureManager(Continent(continent).structureManager()).Build(address(this), _structureId, _count, _hero);
        BuildEvent buildEvent = BuildEvent(eventAddress);

        // Check that there is mamPower enough to build the requested structures.
        require(buildEvent.manPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - buildEvent.manPower();

        // Spend the resouces on the behalf of the user
        Continent(continent).spendEvent(eventAddress); 
        
        // Add the event to the list of activities on the province.
        events.add(eventAddress); // Needs some refactoring, as we do not know the type of event !
        
        _grantRole(EVENT_ROLE, eventAddress); // Enable the event to perform actions on this provice.
    }




    function getStructure(uint256 _id) public view returns(bool, address) {
        return structures.tryGet(_id);
    }

    function getEvents() public view returns(address[] memory) {
        return events.getEvents();
    }

    function setStructure(uint256 _id, address _structureContract) public onlyRole(EVENT_ROLE) onlyEvent {
        structures.set(_id, _structureContract);
    }

    function setPoppulation(uint256 _manPower, uint256 _attrition) public onlyRole(EVENT_ROLE) onlyEvent {
        populationAvailable += _manPower; // Return the manPower to the available pool. Attrition is included in manPower.
        populationTotal -= _attrition; // Remove some of the population because of attrition.
    }

    function payForTime() public onlyRole(EVENT_ROLE) onlyEvent
    {
        Continent(continent).payForTime(msg.sender);
    }

    function completeEvent() public onlyRole(EVENT_ROLE) onlyEvent
    {
        // Province calls continent on behalf of Event.
        events.remove(msg.sender);
    }


    function completeMint() public onlyRole(EVENT_ROLE) onlyEvent
    {
        // Province calls continent on behalf of Event.
        Continent(continent).completeMint(msg.sender);
    }
}