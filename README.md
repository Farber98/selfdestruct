# Selfdestruct vulnerability

selfdestruct(address) function removes all bytecode from a sc and sends all ether stored to the specified address. If specified address is also a contract, no functions get called. In other words, an attacker can forcefully send eth to a target.

## Reproduction

### 📜 Involves two smart contracts.

    1. A vulnerable contract with eth deposited from victims.
    2. A malicious contract that uses selfdestruct and transfers eth to vulnerable contract.

## How to prevent it

🚧 Avoid being dependent on this.balance.

🔐 If exact values should be deposited, use a self-defined variable to safely track deposited eth.
