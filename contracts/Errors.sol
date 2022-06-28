// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >=0.8.4;

/// Invalid balance to transfer. Needed `minRequired` but sent `amount`
/// @param minRequired minimum amount to send.
error InsuffcientFood (uint256 minRequired);
error InsuffcientWood (uint256 minRequired);
error InsuffcientRock (uint256 minRequired);
error InsuffcientIron (uint256 minRequired);
error InsuffcientGold (uint256 minRequired);
