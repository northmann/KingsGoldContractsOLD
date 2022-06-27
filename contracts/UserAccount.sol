// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";



import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// import "./ArmyData.sol";
import "./Interfaces.sol";
import "./Roles.sol";


contract UserAccount is Initializable, IUserAccount {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private provinces;

    address public kingdom;
    address public alliance;

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        kingdom = tx.origin;
        alliance = tx.origin;
    }

    function provinceCount() public view override returns(uint256)
    {
        return provinces.length();
    }

    function addProvince(IProvince _province) public override {
        console.log("addProvince - add province: ",  address(_province));
        provinces.add(address(_province));
    }

    function removeProvince(address _province) public override {
        provinces.remove(_province);
    }

    function getProvince(uint256 index) public view override returns(address) {
        require(index < provinces.length());

        return provinces.at(index);
    }

    function getProvinces() public view override returns(address[] memory) {
        address[] memory result = new address[](provinces.length());
        for(uint256 i = 0; i < provinces.length(); i++)
            result[i] = provinces.at(i);
        return result;
    }


    function setKingdom(address _kingdomAddress) external override {
        kingdom = _kingdomAddress;
    }
    function setAlliance(address _kingdomAddress) external override {
        kingdom = _kingdomAddress;
    }

}
