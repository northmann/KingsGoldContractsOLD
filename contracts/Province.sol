// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import "./Statics.sol"; Only ProvinceID
import "./Interfaces.sol";
import "./Continent.sol";
import "./FarmEvent.sol";
import "./Roles.sol";


//, Roles, 
contract Province is Initializable, Roles, AccessControlUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;

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
    EnumerableSet.AddressSet private building;
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

    function createFarmEvent(uint256 populationUsed) external onlyRoles(OWNER_ROLE, VASSAL_ROLE)  {
        require(populationUsed <= populationAvailable, "not enough population");
        // check that the hero exist and is controlled by user.
        populationAvailable = populationAvailable - populationUsed;

        //(address _provinceAddress, address _hero, uint256 _populationUsed, uint256 _provinceFarmYieldFactor, uint256 _attritionFactor) initializer public {
        BeaconProxy proxy = new BeaconProxy(Continent(continent).farmEventTemplate(), abi.encodeWithSelector( FarmEvent(address(0)).initialize.selector, address(0), populationUsed ));
        Continent(continent).addEvent(address(proxy));
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