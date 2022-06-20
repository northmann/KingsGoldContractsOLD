// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


import "./Interfaces.sol";

abstract contract Event is ERC165Storage, Initializable, OwnableUpgradeable, IEvent, ITimeContract {

    uint256 public creationTime;
    uint256 public timeRequired;
    uint256 public goldForTimeFactor; 

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() payable {
        _disableInitializers();
    }

    function initialize() initializer public virtual {
        __Ownable_init();
        creationTime = block.timestamp;
		_registerInterface(type(IEvent).interfaceId);
		_registerInterface(type(ITimeContract).interfaceId);

    }

    // Perform timed transitions. Be sure to mention
    // this modifier first, otherwise the guards
    // will not take the new stage into account.
    modifier timedExpired() virtual {
        require(block.timestamp >= creationTime + timeRequired,"The time has not expired");
        _;
    }

    /// The cost of the time to complete the transfer.
    function priceForTime() external view override virtual returns(uint256)
    {
        return 0;
    }

    /// When a user has paid for time, this method gets called.
    /// onlyOwner is the Continent contract and not the user.
    function paidForTime() external override virtual onlyOwner
    {
        timeRequired = 0;
    }

    function completeEvent() external override virtual onlyOwner timedExpired
    {
        
    }
}
