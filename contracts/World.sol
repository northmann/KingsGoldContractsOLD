// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

//import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
//import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "./ProvinceBeacon.sol";
import "./GenericAccessControl.sol";
import "./Roles.sol";
import "./Continent.sol";
import "./KingsGold.sol";
import "./Treasury.sol";

contract World is Initializable, Roles, GenericAccessControl, UUPSUpgradeable {

    address[] public continents;

    address public treasury;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _userManager) initializer public {
        userManager =_userManager; // Has to be set here!
    }

    function createWorld(address _continentBeacon) external onlyRole(DEFAULT_ADMIN_ROLE) {
        BeaconProxy proxy = new BeaconProxy(_continentBeacon,abi.encodeWithSelector(Continent(address(0)).initialize.selector, "KingsGold Provinces", address(this), userManager));

        continents.push(address(proxy));
    }

    function getContinentsCount() external view returns(uint256) {
        return continents.length;
    }
    

    function setTreasury(address _treasuryAddress) external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        treasury = _treasuryAddress;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

}