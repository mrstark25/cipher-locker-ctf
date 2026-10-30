// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {CipherLocker} from "../src/CipherLocker.sol";

/// @notice Deploys a fresh CipherLocker to a local Anvil chain so you can play
///         the challenge with `cast` as well as with Exploit.s.sol.
contract Deploy is Script {
    // Public Anvil dev account #0 plays the vault engineer.
    uint256 internal constant DEPLOYER_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function run() external returns (CipherLocker locker) {
        vm.startBroadcast(DEPLOYER_PRIVATE_KEY);
        locker = new CipherLocker();
        vm.stopBroadcast();

        console2.log("CipherLocker deployed at:", address(locker));
    }
}
