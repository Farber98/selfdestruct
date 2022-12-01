// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract NonVulnerableContract {
    uint256 public winningAmount = 5 ether;
    uint256 public balance;
    address payable public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 eth.");
        balance += msg.value;
        require(balance <= winningAmount, "Game over.");

        if (balance == winningAmount) {
            winner = payable(msg.sender);
        }
    }

    function claim() public {
        require(msg.sender == winner, "Only winner.");

        (bool success, ) = winner.call{value: address(this).balance}("");
        require(success, "tx failed.");
    }
}
