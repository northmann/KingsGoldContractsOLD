// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


import "./Province.sol";
import "./Interfaces.sol";
import "./Roles.sol";

abstract contract Event is ERC165Storage, Initializable, Roles, ITimeContract {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public province;

    uint256 public creationTime;
    uint256 public timeRequired;
    uint256 public goldForTime; 
    uint256 public attrition;

    // The cost of resources for this event
    address public hero;

    uint256 public manPower;
    uint256 public food;
    uint256 public wood;
    uint256 public rock;
    uint256 public iron;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // function initialize() initializer public {
    // }


    modifier onlyRole(bytes32 role) {
        require(Province(province).hasRole(role, msg.sender),"Access denied");
        _;
    }


    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(Province(province).hasRole(role1, msg.sender) 
            || Province(province).hasRole(role2, msg.sender)
            // || Province(province).hasRole(MINTER_ROLE, msg.sender)
            // || Province(province).hasRole(DEFAULT_ADMIN_ROLE, msg.sender)
            ,"Access denied");
        _;
    }

    modifier onlyMinter() {
        require(UserAccountManager(Continent(Province(province).continent()).userManager()).hasRole(MINTER_ROLE, msg.sender), "Need MINTER_ROLE in completeMint()");
        _;
    }

    
    // Perform timed transitions. Be sure to mention
    // this modifier first, otherwise the guards
    // will not take the new stage into account.
    modifier timeExpired() virtual {
        require(block.timestamp >= creationTime + timeRequired,"The time has not expired");
        _;
    }

    function setupEvent(address _province) internal onlyInitializing {
        province = _province;
        creationTime = block.timestamp;
		_registerInterface(type(IEvent).interfaceId);
		_registerInterface(type(ITimeContract).interfaceId);

    }


    /// The cost of the time to complete the transfer.
    function priceForTime() external view override virtual returns(uint256)
    {
        return 0;
    }

    /// When a user has paid for time, this method gets called.
    function payForTime() external override virtual onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        Province(province).payForTime();
    }

    function paidForTime() external override virtual onlyMinter
    {
        timeRequired = 0;
    }

    function completeEvent() public override virtual timeExpired onlyRoles(OWNER_ROLE, VASSAL_ROLE)
    {
        
        // Optional if needed call:
        Province(province).completeMint();
    }

    // Only a Contract with minting rights can effectly call this function.
    // In this function only, the Event has minting rights on all commodities.
    function completeMint() public override virtual timeExpired onlyMinter
    {

    }

}
