// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

//import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


import "./Province.sol";
import "./Interfaces.sol";
import "./Roles.sol";

abstract contract Event is ERC165Storage, Initializable, Roles, ITimeContract {
    address public province;

    uint256 public creationTime;
    uint256 public timeRequired;
    uint256 public goldForTimeFactor; 

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() payable {
        _disableInitializers();
    }

    function setupEvent(address _province) internal onlyInitializing {
        province = _province;
        creationTime = block.timestamp;
		_registerInterface(type(IEvent).interfaceId);
		_registerInterface(type(ITimeContract).interfaceId);

    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(Province(province).hasRole(role1, msg.sender) 
            || Province(province).hasRole(role2, msg.sender)
            || Province(province).hasRole(MINTER_ROLE, msg.sender)
            || Province(province).hasRole(DEFAULT_ADMIN_ROLE, msg.sender)
            ,"Access denied");
        _;
    }

    // Perform timed transitions. Be sure to mention
    // this modifier first, otherwise the guards
    // will not take the new stage into account.
    modifier timeExpired() virtual {
        require(block.timestamp >= creationTime + timeRequired,"The time has not expired");
        _;
    }

    /// The cost of the time to complete the transfer.
    function priceForTime() external view override virtual returns(uint256)
    {
        return 0;
    }

    /// When a user has paid for time, this method gets called.
    function paidForTime() external override virtual 
    {
        require(Province(province).hasRole(MINTER_ROLE, msg.sender));
        timeRequired = 0;
    }

    function completeEvent() public override virtual timeExpired
    {
        // Check for origin is owner of Vassal!!!
        
    }
}
