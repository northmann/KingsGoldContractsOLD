// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


import "./Interfaces.sol";
import "./Roles.sol";

abstract contract Event is ERC165Storage, Initializable, Roles, IEvent {
    enum State { Active, PaidFor, Minted, Completed, Cancelled }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    uint256 public constant baseUnit = 1 ether;
    
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

    uint256 public override multiplier; // Multiply the effect of the event. More Farms create more yield etc.
    uint256 public override penalty; // The penalty factor for cancelling the event, if any.
    uint256 public override rounds; // Repeat the event a number of rounds. 
    uint256 public override manPower;
    uint256 public override foodAmount;
    uint256 public override woodAmount;
    uint256 public override rockAmount;
    uint256 public override ironAmount;


    modifier onlyMinter() {
        require(world.userAccountManager().hasRole(MINTER_ROLE, msg.sender), "Caller do not have the MINTER_ROLE");
        _;
    }

    modifier onlyProvince() {
        require(world.userAccountManager().hasRole(PROVINCE_ROLE, msg.sender), "Caller do not have the PROVINCE_ROLE");
        require(msg.sender == address(province),"The caller is not the event's province");
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

    function setupEvent(IProvince _province) internal onlyInitializing {
        province = _province;
        if(address(_province) != address(0))
            world = _province.world();
        creationTime = block.timestamp;
		_registerInterface(type(IEvent).interfaceId);
        state = State.Active;
    }


    /// The cost of the time to complete the event with rounds and multipliers.
    function priceForTime() external view override virtual returns(uint256)
    {
        // Check if the time needed to complete the event is over, then just return zero cost.
		if((block.timestamp - creationTime) >= (timeRequired * rounds * multiplier)) return 0;

        uint256 baseCost = province.world().baseGoldCost();
        console.log("BaseCost: ", baseCost);
        console.log("multiplier: ", multiplier);
        console.log("goldForTime: ", goldForTime);
        console.log("rounds: ", rounds);
        uint256 basePrice = ((goldForTime * baseCost) / 1e18);
        console.log("basePrice: ", basePrice);
		uint256 totalCost = multiplier * rounds * basePrice;
        console.log("totalCost: ", totalCost);
        
        uint256 reducedCost = reducedAmountOnTimePassed(totalCost);
        console.log("reducedCost: ", totalCost);

        // uint256 factor = ((block.timestamp - creationTime) * 1e18) / (timeRequired * rounds * multiplier);
		// uint256 reducedCost = totalCost - ((totalCost * factor) / 1e18);

        return reducedCost;
    }

    /// When a user has paid for time, this method gets called.
    function payForTime() public override virtual onlyProvince isState(State.Active)
    {
    }

    // Callback funcation from above after the event has been paid for.
    function paidForTime() public override virtual onlyProvince isState(State.Active)
    {
        state = State.PaidFor;
        timeRequired = 0;
    }

    function complete() public override virtual timeExpired onlyProvince notState(State.Completed) notState(State.Cancelled)
    {
        updatePopulation();
        state = State.Completed;
    }

    function cancel() public override virtual onlyProvince notState(State.Minted) notState(State.Completed) notState(State.Cancelled)
    {
        // E.g;
        // Calculate penalty
        updatePopulation();
        state = State.Cancelled;
    }


    function penalizeAmount(uint256 _amount) internal view virtual returns(uint256) {
        uint256 reducedAmount = reducedAmountOnTimePassed(_amount);
        uint256 amountLeft = (_amount - reducedAmount);
        amountLeft = ((amountLeft * penalty) / 1e18);
         
        return amountLeft;
    }

    function reducedAmountOnTimePassed(uint256 _amount) internal view returns(uint256)
    {
		if((block.timestamp - creationTime) >= (timeRequired * rounds)) return 0;

        uint256 factor = ((block.timestamp - creationTime) * 1e18) / (timeRequired * rounds);
		uint256 reducedCost = (_amount - ((_amount * factor) / 1e18));

        return reducedCost;
    }

    function updatePopulation() internal virtual
    {
        assert(attrition <= 1e18); // Cannot be more than 100%
        // Calc mamPower Attrition

        uint256 attritionCost = ((manPower * attrition) / baseUnit); // Calculate the percentage of the attrition.
        uint256 reducedAmount = reducedAmountOnTimePassed(attritionCost);
        attritionCost = attritionCost - reducedAmount; // Attrition increases over time.
        uint256 manPowerLeft = manPower - attritionCost;

        province.setPopulationAvailable(province.populationAvailable() + manPowerLeft);
        province.setPopulationTotal(province.populationTotal() - attritionCost);
    }

}
