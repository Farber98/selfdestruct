// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NonVulnerableContract.sol";
import "../src/VulnerableContract.sol";
import "../src/MaliciousContract.sol";

contract Reentrancy is Test {
    VulnerableContract vulnerable;
    NonVulnerableContract nonVulnerable;
    MaliciousContract maliciousVulnerable;
    MaliciousContract maliciousNonVulnerable;

    address payable vulnerableContractDeployer1 = payable(address(0x1));
    address payable maliciousContractDeployer2 = payable(address(0x2));
    address payable victim3 = payable(address(0x3));
    address payable victim4 = payable(address(0x4));
    uint256 victimValue = 4 ether;
    uint256 attackerValue = 1 ether;

    function setUp() public {
        vm.startPrank(vulnerableContractDeployer1);
        vulnerable = new VulnerableContract();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousVulnerable = new MaliciousContract();
        vm.stopPrank();

        vm.startPrank(vulnerableContractDeployer1);
        nonVulnerable = new NonVulnerableContract();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousNonVulnerable = new MaliciousContract();
        vm.stopPrank();
    }

    function testVulnerableContractWithSelfDestruct() public {
        vm.startPrank(victim3);
        assertEq(victim3.balance, 0);
        vm.deal(victim3, victimValue);
        assertEq(victim3.balance, victimValue);
        assertEq(address(vulnerable).balance, 0 ether);
        vulnerable.deposit{value: 1 ether}();
        vulnerable.deposit{value: 1 ether}();
        vulnerable.deposit{value: 1 ether}();
        vulnerable.deposit{value: 1 ether}();
        assertEq(address(vulnerable).balance, victimValue);
        assertEq(victim3.balance, 0 ether);
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, attackerValue);
        maliciousVulnerable.attack{value: 1 ether}(
            payable(address(vulnerable))
        );
        vm.stopPrank();

        // funds gets locked with addr 0 as winner.
        assertEq(vulnerable.winner(), address(0));
    }

    function testNonVulnerableContractWithSelfDestruct() public {
        vm.startPrank(victim3);
        assertEq(victim3.balance, 0);
        vm.deal(victim3, victimValue);
        assertEq(victim3.balance, victimValue);
        assertEq(address(nonVulnerable).balance, 0 ether);
        nonVulnerable.deposit{value: 1 ether}();
        nonVulnerable.deposit{value: 1 ether}();
        nonVulnerable.deposit{value: 1 ether}();
        nonVulnerable.deposit{value: 1 ether}();
        assertEq(address(nonVulnerable).balance, victimValue);
        assertEq(victim3.balance, 0 ether);
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, attackerValue);
        maliciousNonVulnerable.attack{value: 1 ether}(
            payable(address(nonVulnerable))
        );
        vm.stopPrank();

        // balance variable still 4 ether.
        assertEq(nonVulnerable.balance(), victimValue);
        // balance of the contract is  5 ether.
        assertEq(address(nonVulnerable).balance, victimValue + attackerValue);

        // "victim" can win the game and gets bonus selfdestruct eth.
        vm.startPrank(victim4);
        assertEq(victim4.balance, 0);
        vm.deal(victim4, attackerValue);
        nonVulnerable.deposit{value: attackerValue}();
        assertEq(nonVulnerable.balance(), 5 ether);
        assertEq(nonVulnerable.winner(), victim4);
        nonVulnerable.claim();
        assertEq(victim4.balance, victimValue + 2 * attackerValue);
        assertEq(address(nonVulnerable).balance, 0);
        vm.stopPrank();
    }
}
