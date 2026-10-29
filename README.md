# CipherLocker — Smart Contract CTF (Moderate)

> "Nothing on-chain is private. Not even the stuff that isn't in storage."

## Briefing
A vault engineer split the master password into **three fragments** and hid each
in a different "private" place inside `CipherLocker`. You have **3 attempts**.
A wrong guess doesn't revert: it burns an attempt. Three misses and the locker
bricks permanently.

**Win condition:** `locked == false` and `owner == player`.

| | |
|---|---|
| Difficulty | Moderate (Ethernaut "Vault" → next level) |
| Category | Sensitive on-chain data / EVM storage layout |
| Est. time | 30–90 min |
| Tools | Foundry (`vm.load`, `address.code`) or `cast storage` / `cast code` |

## Setup
Requires [Foundry](https://book.getfoundry.sh/getting-started/installation).
```bash
git clone --recursive https://github.com/mrstark25/cipher-locker-ctf.git
cd cipher-locker-ctf
# already cloned without --recursive? run: git submodule update --init
forge test --match-contract CipherLockerChallenge -vv
```
Write your exploit in `test/CipherLocker.t.sol` between the markers. The test
fails until you solve it. Rules: don't edit `src/` or `setUp()`, and don't use
cheatcodes that write state (`vm.store`, `vm.etch`, `vm.deal`, extra `vm.prank`).
Reading state with `vm.load` and `address.code` is allowed.

## Hints (reveal one at a time)
<details><summary>Hint 1</summary>Two variables share slot 1. Which one sits in the low-order bytes?</details>
<details><summary>Hint 2</summary>Dynamic array data lives at <code>keccak256(slot)</code>. How many <code>bytes8</code> fit in one 32-byte slot?</details>
<details><summary>Hint 3</summary><code>immutable</code> variables are not in storage. Where do they go after deployment?</details>
<details><summary>Hint 4</summary>You can read <code>passwordHash</code>. That means you can test candidates for free before spending an attempt.</details>
<details><summary>Hint 5</summary>Immutables are inlined as a 32-byte <code>PUSH32</code> (opcode <code>0x7f</code>); a <code>bytesN</code> is left-aligned.</details>

## What players learn
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
