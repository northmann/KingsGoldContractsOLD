// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

//import "./Statics.sol"; Only ProvinceID
import "./BuildEvent.sol";
//import "./YieldEvent.sol";
import "./Interfaces.sol";
import "./Continent.sol";
import "./Roles.sol";
import "./EventFactory.sol";
import "./Structure.sol";
import "./EventSetExtensions.sol";




//, Roles, 
contract Province is Initializable, Roles, AccessControlUpgradeable, IProvince {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EventListExtensions for EnumerableMap.AddressToUintMap;
    using EventListExtensions for EventListExtensions.History;

    IContinent public override continent;
    IWorld public override world;

    string public name;

    address public owner;
    address public vassal;

    uint32 public positionX;
    uint32 public positionY;

    uint32 public plains;   // Food
    uint32 public forest;   // Wood
    uint32 public mountain; // Stone
    uint32 public hills;    // Gold and iron ore

    uint256 public override populationTotal;
    uint256 public override populationAvailable;
    address public armyContract;

    EnumerableMap.AddressToUintMap internal events;
    IEvent public override latestEvent; // Mostly for testing purposes

    EventListExtensions.History internal eventHistory;

    EnumerableMap.UintToAddressMap private structures;

    EnumerableSet.AddressSet private incomingTransfers;
    EnumerableSet.AddressSet private insideTransfers;
    EnumerableSet.AddressSet private outgoingTransfers;


    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(hasRole(role1, msg.sender) || hasRole(role2, msg.sender),"onlyRoles: Access denied");
        _;
    }

    modifier onlyEvent() {
        require(events.contains(msg.sender)); //Event must be listed on the province's events.
        require(hasRole(EVENT_ROLE, msg.sender),"Event do not have the EVENT_ROLE");
        _;
    }

    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, address _owner, IContinent _continent) initializer public {
        __AccessControl_init();
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(MINTER_ROLE, address(_continent));
        continent = _continent;
        world = continent.world();
        name = _name;
        populationAvailable = 100;
        populationTotal = populationAvailable;
    }

    function setVassal(address _user) external override onlyRole(OWNER_ROLE)
    {
        _grantRole(VASSAL_ROLE, _user);
    }

    function removeVassal(address _user) external override onlyRole(OWNER_ROLE)
    {
        _revokeRole(VASSAL_ROLE, _user);
    }

    function createStructureEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        console.log("createStructure start");

        console.log("createStructure call CreateBuildEvent");
        // Create a new Build event        
        IBuildEvent buildEvent = world.eventFactory().CreateBuildEvent(this, _structureId, _multiplier, _rounds, _hero);
        
        console.log("createStructure add event");
        // Add the event to the list of activities on the province.
        events.set(address(buildEvent), buildEvent.typeId()); 
        latestEvent = buildEvent;

        console.log("createStructure grant role");
        _grantRole(EVENT_ROLE, address(buildEvent)); // Enable the event to perform actions on this provice.

        console.log("createStructure check manpower");
        // Check that there is mamPower enough to build the requested structures.
        require(buildEvent.manPower() <= populationAvailable, "not enough population");

        populationAvailable = populationAvailable - buildEvent.manPower();

        console.log("createStructure spendEvent");
        // Spend the resouces on the behalf of the user
        continent.spendEvent(buildEvent, msg.sender); 
        
       
    }

    function createYieldEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        //IProvince provinceInstance = IProvince(msg.sender)

        (bool structureExist, address structureAddress) = getStructure(_structureId);
        require(structureExist,"YieldStructure do not exist on provice");

        IYieldStructure structure = IYieldStructure(structureAddress);
        require(structure.availableAmount() < _multiplier, "Insufficient structures");

        // Create a new Build event        
        IYieldEvent yieldEvent =  world.eventFactory().CreateYieldEvent(this, structure, msg.sender, _multiplier, _rounds, _hero);
        // Add the event to the list of activities on the province.
        events.set(address(yieldEvent), yieldEvent.typeId()); // Needs some refactoring, as we do not know the type of event !
        latestEvent = yieldEvent;

        // Check that there is mamPower enough to build the requested structures.
        require(yieldEvent.manPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - yieldEvent.manPower();

        structure.setAvailableAmount(structure.availableAmount() - _multiplier);

        
        _grantRole(EVENT_ROLE, address(yieldEvent)); // Enable the event to perform actions on this provice.
    }

    function createGrowPopulationEvent(uint256 _rounds, uint256 _manPower, uint256 _hero) public override onlyRoles(OWNER_ROLE, VASSAL_ROLE) returns(IPopulationEvent) {
        IPopulationEvent populationEvent =  world.eventFactory().createGrowPopulationEvent(this,  _rounds, _manPower, _hero);

        // Check that there is mamPower enough to build the requested structures.
        require(_manPower <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - _manPower;

        // Add the event to the list of activities on the province.
        events.set(address(populationEvent), populationEvent.typeId()); // Needs some refactoring, as we do not know the type of event !
        latestEvent = populationEvent;
        
        _grantRole(EVENT_ROLE, address(populationEvent)); // Enable the event to perform actions on this provice.

        return populationEvent;
    }

    function getStructure(uint256 _id) public view override returns(bool, address) {
        return structures.tryGet(_id);
    }

    function getEvents() public view override returns(EventListExtensions.ActionEvent[] memory)  {
        return events.getEvents();
    }

    function setStructure(uint256 _id, IStructure _structureContract) public override onlyEvent {
        structures.set(_id, address(_structureContract));
    }

    function setPopulationTotal(uint256 _multiplier) public override onlyRole(EVENT_ROLE) onlyEvent {
        populationTotal = _multiplier;

    }
    function setPopulationAvailable(uint256 _multiplier) public override onlyRole(EVENT_ROLE) onlyEvent {
        populationAvailable = _multiplier;
    }


    function payForTime(IEvent _event) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not an event contract");
        require(events.contains(address(_event)),"Event unknown by province");
        require(hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");

        _event.payForTime(); // More check locally

        // Execute the payment
        continent.payForTime(_event, msg.sender);

        _event.paidForTime();
    }

    function completeEvent(IEvent _event) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not an event contract");
        require(events.contains(address(_event)),"Event unknown by province");
        require(hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");

        if(ERC165Checker.supportsInterface(address(_event), type(IYieldEvent).interfaceId)) {
            // Province calls continent on behalf of Event.
            continent.completeMint(IYieldEvent(address(_event)));
        }

        _event.complete();

        events.remove(address(_event));
        eventHistory.add(address(_event), _event.typeId());       

    }

    function cancelEvent(IEvent _event) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        require(ERC165Checker.supportsInterface(address(_event), type(IEvent).interfaceId), "Not an event contract");
        require(events.contains(address(_event)),"Event unknown by province");
        require(hasRole(EVENT_ROLE, address(_event)),"Event do not have the EVENT_ROLE");

        if(ERC165Checker.supportsInterface(address(_event), type(IYieldEvent).interfaceId)) {
            
            IYieldEvent yieldEvent = IYieldEvent(address(_event));
            yieldEvent.penalizeCommodities(); 
            // Province calls continent on behalf of Event.
            continent.completeMint(yieldEvent);
        }

        _event.cancel();

        events.remove(address(_event));
        eventHistory.add(address(_event), _event.typeId());       

    }


    function containsEvent(IEvent _event) public view override returns(bool)
    {
        return events.contains(address(_event));
    }
}