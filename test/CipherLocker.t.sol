// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CipherLocker} from "../src/CipherLocker.sol";

contract CipherLockerChallenge is Test {
    CipherLocker internal locker;
    address internal deployer = makeAddr("vault-engineer");
    address internal player = makeAddr("player");

    function setUp() public {
        vm.prevrandao(keccak256(abi.encode(vm.unixTime())));
        vm.warp(1_700_000_000 + (vm.unixTime() % 1_000_000));
        vm.prank(deployer);
        locker = new CipherLocker();
    }

    function testExploit() public {
        vm.startPrank(player, player);

        // ════════════ YOUR EXPLOIT HERE ════════════

        // ═══════════════════════════════════════════

        vm.stopPrank();
        _isSolved();
    }

    function _isSolved() internal view {
        assertFalse(locker.locked(), "locker still locked");
        assertEq(locker.owner(), player, "player is not owner");
    }
}
