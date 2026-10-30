# CipherLocker — Smart Contract CTF

> "Nothing on-chain is private. Not even the stuff that isn't in storage."

| Difficulty | Focus | Est. time |
|---|---|---|
| Intermediate | Sensitive on-chain data · EVM storage layout · bytecode | 30–90 min |

A vault engineer split the master password into **three fragments** and hid
each one in a different "private" place inside `CipherLocker`. A wrong guess
doesn't revert: it burns an attempt. Three misses and the locker bricks forever.

## Goal
- Unlock the locker (`locked == false`).
- Become the owner of the contract (`owner == player`).

## Your Task
Read [`src/CipherLocker.sol`](src/CipherLocker.sol), then complete
[`script/Exploit.s.sol`](script/Exploit.s.sol).

```solidity
function run() external {
    CipherLocker locker = CipherLocker(vm.envAddress("TARGET"));

    vm.startBroadcast(PLAYER_PRIVATE_KEY);

    // ════════════ YOUR EXPLOIT HERE ════════════

    // ═══════════════════════════════════════════

    vm.stopBroadcast();
}
```

## Starting Facts
- Owner: the deployer (the vault engineer)
- `locked`: `true`
- Attempts used: `0` of `3`
- Player balance: 1 ether
- Player: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` (public Anvil dev account #1)

## Hints (0/5)
<details><summary>Hint 1 · CipherLocker.sol</summary>Two variables share slot 1. Which one sits in the low-order bytes?</details>
<details><summary>Hint 2 · CipherLocker.sol</summary>Dynamic array data lives at <code>keccak256(slot)</code>. How many <code>bytes8</code> fit in one 32-byte slot?</details>
<details><summary>Hint 3 · CipherLocker.sol</summary><code>immutable</code> variables are not in storage. Where do they go after deployment?</details>
<details><summary>Hint 4 · Exploit.s.sol</summary>You can read <code>passwordHash</code>. That means you can test candidates for free before spending an attempt.</details>
<details><summary>Hint 5 · Exploit.s.sol</summary>Immutables are inlined as a 32-byte <code>PUSH32</code> (opcode <code>0x7f</code>); a <code>bytesN</code> is left-aligned.</details>

## How this CTF works
Requires [Foundry](https://book.getfoundry.sh/getting-started/installation).

```bash
git clone --recursive https://github.com/mrstark25/cipher-locker-ctf.git
cd cipher-locker-ctf
# already cloned without --recursive? run: git submodule update --init
```

**Verify your solution.** The verifier in `test/CipherLocker.t.sol` deploys a
fresh target with new randomness, runs your `Exploit.s.sol`, then asserts the
goal. It fails until you solve the challenge.
```bash
forge test --match-contract CipherLockerChallenge -vv
```

**Play against a local chain (optional).**
```bash
anvil                                                    # terminal 1
forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
TARGET=<deployed address> forge script script/Exploit.s.sol \
  --rpc-url http://127.0.0.1:8545 --broadcast
```
You can also poke the deployed contract with `cast storage` and `cast code`.

**Rules**
- Edit only `script/Exploit.s.sol`. Leave `src/` and `test/` as they are.
- Reading state is allowed (`vm.load`, `address.code`, `cast storage`, `cast code`).
- Don't use cheatcodes that write state (`vm.store`, `vm.etch`, `vm.deal`, `vm.prank`).

The keys in `script/` are Anvil's public dev keys. Never send real funds to them.

## What you'll learn
1. Packed storage slots and byte ordering (`bytes16` + `uint128` in one slot)
2. Dynamic array slot math and sub-slot packing
3. `constant` vs `immutable` vs storage, and why immutables are in runtime bytecode
4. Off-chain verification against a leaked hash (don't waste on-chain attempts)
5. Spotting decoys (`MASTER_KEY`, the `notes` mapping)

## Solution
No solution is published here, so the puzzle isn't spoiled. Solved it? Open an
issue titled `Solved: <your handle>` with a short write-up, without code.

## Credits
Written by Nikhil Baghel. Inspired by the
[Ethernaut](https://ethernaut.openzeppelin.com/) *Vault* and *Privacy* levels.

## License
[MIT](LICENSE)
