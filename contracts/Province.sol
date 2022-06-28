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

    uint256 public populationTotal;
    uint256 public populationAvailable;
    address public armyContract;

    EnumerableMap.AddressToUintMap internal events;
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

    function setVassal(address _user) external onlyRole(OWNER_ROLE)
    {
        _setupRole(VASSAL_ROLE, _user);
    }

    function createStructure(uint256 _structureId, uint256 _count, uint256 _hero) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        console.log("createStructure start");

        console.log("createStructure call CreateBuildEvent");
        // Create a new Build event        
        IBuildEvent buildEvent = world.eventFactory().CreateBuildEvent(this, _structureId, _count, _hero);
        
        console.log("createStructure check manpower");
        // Check that there is mamPower enough to build the requested structures.
        require(buildEvent.ManPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - buildEvent.ManPower();

        console.log("createStructure spendEvent");
        // Spend the resouces on the behalf of the user
        continent.spendEvent(buildEvent); 
        
        console.log("createStructure add event");
        // Add the event to the list of activities on the province.
        events.set(address(buildEvent), buildEvent.Id()); // Needs some refactoring, as we do not know the type of event !
        
        console.log("createStructure grant role");
        _grantRole(EVENT_ROLE, address(buildEvent)); // Enable the event to perform actions on this provice.
    }

    function createYieldEvent(uint256 _structureId, uint256 _count, uint256 _hero) external override onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        //IProvince provinceInstance = IProvince(msg.sender)

        (bool structureExist, address structureAddress) = getStructure(_structureId);
        require(structureExist,"YieldStructure do not exist on provice");

        IYieldStructure structure = IYieldStructure(structureAddress);
        require(structure.availableAmount() < _count, "Insufficient structures");

        // Create a new Build event        
        IYieldEvent yieldEvent =  world.eventFactory().CreateYieldEvent(this, structure, msg.sender, _count, _hero);

        // Check that there is mamPower enough to build the requested structures.
        require(yieldEvent.ManPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - yieldEvent.ManPower();

        structure.setAvailableAmount(structure.availableAmount() - _count);

        // Add the event to the list of activities on the province.
        events.set(address(yieldEvent), yieldEvent.Id()); // Needs some refactoring, as we do not know the type of event !
        
        _grantRole(EVENT_ROLE, address(yieldEvent)); // Enable the event to perform actions on this provice.
    }



    function getStructure(uint256 _id) public view override returns(bool, address) {
        return structures.tryGet(_id);
    }



    function getEvents() public view override returns(EventListExtensions.ActionEvent[] memory)  {
        return events.getEvents();
    }

    function setStructure(uint256 _id, IStructure _structureContract) public override onlyRole(EVENT_ROLE) onlyEvent {
        structures.set(_id, address(_structureContract));
    }

    function setPoppulation(uint256 _manPower, uint256 _attrition) public override onlyRole(EVENT_ROLE) onlyEvent {
        populationAvailable += _manPower; // Return the manPower to the available pool. Attrition is included in manPower.
        populationTotal -= _attrition; // Remove some of the population because of attrition.
    }

    function payForTime(IEvent _event) public override onlyRole(MINTER_ROLE) onlyEvent
    {
        require(events.contains(address(_event)),"Event unknown by province");

        _event.payForTime(); // More check locally
    }

    function completeEvent(IEvent _event) public override  onlyRole(MINTER_ROLE) onlyEvent
    {
        require(events.contains(address(_event)),"Event unknown by province");
        require(address(_event.province()) == address(this),"Event point to invalid province");
                

        setPoppulation(_event.ManPower(), 0);

        _event.completeEvent();

        // Province calls continent on behalf of Event.
        events.remove(address(_event));
        eventHistory.add(address(_event), _event.Id());       

    }

    function containsEvent(IEvent _event) public view override returns(bool)
    {
        return events.contains(address(_event));
    }


    // function completeMint() public override onlyRole(EVENT_ROLE) onlyEvent
    // {
    //     // Province calls continent on behalf of Event.
    //     continent.completeMint(msg.sender);
    // }
}