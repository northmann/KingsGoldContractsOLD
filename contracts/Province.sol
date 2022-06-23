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
import "./BuildingManager.sol";
import "./Building.sol";



//, Roles, 
contract Province is Initializable, Roles, AccessControlUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

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

    EnumerableSet.AddressSet private work;

    EnumerableMap.UintToAddressMap private buildings;

    EnumerableSet.AddressSet private incomingTransfers;
    EnumerableSet.AddressSet private insideTransfers;
    EnumerableSet.AddressSet private outgoingTransfers;


    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(hasRole(role1, msg.sender) || hasRole(role2, msg.sender),"Access denied");
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

    function createBuilding(uint256 _buildingId, uint256 _count, uint256 _hero) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        // check that the hero exist and is controlled by user.
        
        // Create a new Build event        
        address eventAddress = BuildingManager(Continent(continent).buildingManager()).Build(address(this), _buildingId, _count, _hero);
        BuildEvent buildEvent = BuildEvent(eventAddress);

        // Check that there is mamPower enough to build the requested buildings.
        require(buildEvent.manPower() <= populationAvailable, "not enough population");
        populationAvailable = populationAvailable - buildEvent.manPower();

        // Spend the resouces on the behalf of the user
        Continent(continent).spendEvent(eventAddress); 
        
        // Add the event to the continent list, for security.
        Continent(continent).addEvent(eventAddress);

        // Add the event to the list of activities on the province.
        work.add(eventAddress); // Needs some refactoring, as we do not know the type of event !
    }


    //TODO: What onlyRole(PROVINCE_ROLE) ?
    function setBuilding(uint256 _id, address _buildingContract) public  {
        buildings.set(_id, _buildingContract);
    }

    //TODO: What onlyRole(PROVINCE_ROLE) ?
    function getBuilding(uint256 _id) public view returns(bool, address) {
        return buildings.tryGet(_id);
    }

    function completeEvent(address _eventContract) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        Continent(continent).completeEvent(_eventContract);

        // update the population!

        // populationAvailable += farm.populationSurvived();
        // populationTotal -= (farm.populationUsed() - farm.populationSurvived());

        // Kill the contract in the end!
    }

}