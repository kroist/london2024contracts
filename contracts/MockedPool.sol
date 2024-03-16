// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract MockedPool {

    address owner;
    IERC20 public token;

    constructor(
        address _tokenAddress
    ) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }
    
    function deposit(
        uint256 amount
    ) public {
        token.transferFrom(msg.sender, address(this), amount);
        /// CREATE YIELD!!!
    }

    function withdraw(
        uint256 amount
    ) public onlyOwner {
        token.transfer(msg.sender, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
