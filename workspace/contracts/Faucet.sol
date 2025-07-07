// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    // Event for tracking withdrawals
    event Withdrawal(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    
    // Main withdrawal function
    function getETH(uint256 amount) external {
        require(address(this).balance >= amount, "Insufficient funds in faucet");
        
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    // Accept ETH deposits for refilling the faucet
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    // Check faucet balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Get faucet balance in ETH (for easier reading)
    function getBalanceInETH() external view returns (uint256) {
        return address(this).balance / 1 ether;
    }
}