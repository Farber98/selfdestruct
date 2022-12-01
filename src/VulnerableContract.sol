// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VulnerableContract {
    uint256 public winningAmount = 5 ether;
    address payable public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 eth.");

        uint256 balance = address(this).balance;
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
