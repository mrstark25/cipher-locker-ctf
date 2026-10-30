// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CipherLocker} from "../src/CipherLocker.sol";
import {Exploit} from "../script/Exploit.s.sol";

/// @notice Verifier. Deploys the target, runs your Exploit.s.sol, then checks
///         the win condition. Don't edit this file.
contract CipherLockerChallenge is Test {
    // Address of the public Anvil dev key used in Exploit.s.sol
    address internal constant PLAYER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 internal constant PLAYER_START_BALANCE = 1 ether;

    CipherLocker internal locker;
    address internal deployer = makeAddr("vault-engineer");

    function setUp() public {
        vm.prevrandao(keccak256(abi.encode(vm.unixTime())));
        vm.warp(1_700_000_000 + (vm.unixTime() % 1_000_000));
        vm.prank(deployer);
        locker = new CipherLocker();

        vm.deal(PLAYER, PLAYER_START_BALANCE);
        vm.setEnv("TARGET", vm.toString(address(locker)));
    }

    function testExploit() public {
        _runExploit();
        _isSolved();
    }

    function _runExploit() internal virtual {
        new Exploit().run();
    }

    function _isSolved() internal view {
        assertFalse(locker.locked(), "locker still locked");
        assertEq(locker.owner(), PLAYER, "player is not owner");
    }
}
