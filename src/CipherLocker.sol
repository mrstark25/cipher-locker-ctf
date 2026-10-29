// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 *   ____ _       _               _               _
 *  / ___(_)_ __ | |__   ___ _ __| |    ___   ___| | _____ _ __
 * | |   | | '_ \| '_ \ / _ \ '__| |   / _ \ / __| |/ / _ \ '__|
 * | |___| | |_) | | | |  __/ |  | |__| (_) | (__|   <  __/ |
 *  \____|_| .__/|_| |_|\___|_|  |_____\___/ \___|_|\_\___|_|
 *         |_|
 *
 *  The vault engineer split the master password into three fragments and
 *  hid each one in a "private" place. You get THREE guesses. After that the
 *  locker bricks itself forever.
 *
 *  Goal: call unlock() with the correct password and become the owner.
 */
contract CipherLocker {
    // ───────────── slot 0 ─────────────
    address public owner;
    bool public locked;
    uint8 public attempts;
    uint64 private sealedAt;

    // ───────────── slot 1 ─────────────
    bytes16 private fragA;
    uint128 private nonce;

    // ───────────── slot 2 ─────────────
    bytes8[] private shards;

    // ───────────── slot 3 ─────────────
    mapping(address => bytes32) private notes;

    // ───────────── slot 4 ─────────────
    bytes32 private passwordHash;

    // ─────────── not in storage ───────────
    bytes32 public constant MASTER_KEY = keccak256("letmein");
    uint8 public constant MAX_ATTEMPTS = 3;
    bytes8 private immutable fragC;

    event Attempt(address indexed who, bool success, uint8 attemptsUsed);
    event Unlocked(address indexed by);

    constructor() {
        owner = msg.sender;
        locked = true;
        sealedAt = uint64(block.timestamp);

        bytes32 seed = keccak256(
            abi.encode(block.prevrandao, block.timestamp, msg.sender, address(this))
        );

        fragA = bytes16(seed);
        nonce = uint128(uint256(seed));

        for (uint256 i; i < 8; ++i) {
            shards.push(bytes8(keccak256(abi.encode(seed, i))));
        }

        bytes8 c = bytes8(keccak256(abi.encode(seed, "C")));
        fragC = c;

        notes[msg.sender] = MASTER_KEY;

        passwordHash = keccak256(abi.encodePacked(fragA, shards[_shardIndex()], c));
    }

    /// @notice password = fragA (16 bytes) ‖ shards[nonce % 8] (8 bytes) ‖ fragC (8 bytes)
    function unlock(bytes32 password) external returns (bool) {
        require(locked, "already open");
        require(attempts < MAX_ATTEMPTS, "locker bricked");

        if (keccak256(abi.encodePacked(password)) != passwordHash) {
            attempts++;
            emit Attempt(msg.sender, false, attempts);
            return false;
        }

        locked = false;
        owner = msg.sender;
        emit Attempt(msg.sender, true, attempts);
        emit Unlocked(msg.sender);
        return true;
    }

    /// @notice Lets auditors verify this locker instance hasn't been swapped out
    function checksum() external view returns (bytes32) {
        return keccak256(abi.encodePacked(fragC, sealedAt));
    }

    function _shardIndex() internal view returns (uint256) {
        return uint256(nonce) % shards.length;
    }
}
