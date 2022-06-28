// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


import "./Interfaces.sol";
import "./Roles.sol";

abstract contract Event is ERC165Storage, Initializable, Roles, IEvent {
    enum State { Active, PaidFor, Minted, Completed }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    
    State public state;

    IProvince public override province;
    //address public continent;
    IWorld public override world;

    uint256 public creationTime;
    uint256 public timeRequired;
    uint256 public goldForTime; 
    uint256 public attrition;

    // The cost of resources for this event
    address public hero;

    uint256 internal manPower;
    uint256 internal foodAmount;
    uint256 public woodAmount;
    uint256 public rockAmount;
    uint256 public ironAmount;


    modifier onlyMinter() {
        require(world.userAccountManager().hasRole(MINTER_ROLE, msg.sender), "Need MINTER_ROLE in completeMint()");
        _;
    }


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // function initialize() initializer public {
    // }

    modifier notState(State _state) {
        require(_state != state, "Illegal state");
        _;
    }

    modifier isState(State _state) {
        require(_state == state, "Illegal state");
        _;
    }


    modifier onlyWorldRole(bytes32 role) {
        require(world.userAccountManager().hasRole(role, msg.sender),"Access denied");
        _;
    }


    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(province.hasRole(role1, msg.sender) 
            || province.hasRole(role2, msg.sender)
            // || Province(province).hasRole(MINTER_ROLE, msg.sender)
            // || Province(province).hasRole(DEFAULT_ADMIN_ROLE, msg.sender)
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

    function ManPower() public view override returns(uint256){
        return manPower;
    }

    function FoodAmount() public view  override returns(uint256)
    {
        return foodAmount;
    }


    function setupEvent(IProvince _province) internal onlyInitializing {
        province = _province;
        world = _province.world();
        creationTime = block.timestamp;
		_registerInterface(type(IEvent).interfaceId);
        state = State.Active;
    }


    /// The cost of the time to complete the transfer.
    function priceForTime() external view override virtual returns(uint256)
    {
        return goldForTime;
    }

    /// When a user has paid for time, this method gets called.
    function payForTime() external override virtual onlyWorldRole(PROVINCE_ROLE) isState(State.Active)
    {
    }

    // Callback funcation from above after the event has been paid for.
    function paidForTime() external override virtual onlyMinter isState(State.Active)
    {
        state = State.PaidFor;
        timeRequired = 0;
    }

    function completeEvent() public override virtual timeExpired onlyWorldRole(PROVINCE_ROLE) notState(State.Completed)
    {
        state = State.Completed;
    }
}
