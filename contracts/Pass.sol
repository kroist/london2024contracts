// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './interface/ISemaphoreVerifier.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Pass {
    uint256 periodSeconds;
    uint256 public passCostPerPeriod;
    IERC20 public passPaymentToken;
    uint256 public passesCount;
    ISemaphoreVerifier public semaphoreVerifier;

    uint256 public tillTimestamp;
    
    uint256 internal immutable externalNullifierHash;

    mapping(address => uint256) passId;
    mapping(address => uint256) passTillTimestamp;

    error InsufficientAllowance(uint256 provided, uint256 required);
    error NotPassHolder(address user);
    error PassExpired(address user, uint256 validTillTimestamp);

    function hashToField(bytes memory value) internal pure returns (uint256) {
		return uint256(keccak256(abi.encodePacked(value))) >> 8;
	}

    constructor(
        uint256 _periodSeconds,
        uint256 _passCostPerPeriod,
        address _passPaymentToken,
        address _semaphoreVerifier,
        string memory _appId,
        string memory _action
    ) {
        periodSeconds = _periodSeconds;
        passCostPerPeriod = _passCostPerPeriod;
        passPaymentToken = IERC20(_passPaymentToken);
        semaphoreVerifier = ISemaphoreVerifier(_semaphoreVerifier);
        externalNullifierHash = hashToField(
            abi.encodePacked(
                hashToField(abi.encodePacked(_appId)),
                _action
            )
        );
    }

    function processPayment(
        uint256 paymentPeriod
    ) private {
        uint256 requiredPayment = passCostPerPeriod * paymentPeriod;
        uint256 allowance = passPaymentToken.allowance(msg.sender, address(this));
        if (allowance < requiredPayment) {
            revert InsufficientAllowance(allowance, requiredPayment);
        }
        passPaymentToken.transferFrom(msg.sender, address(this), requiredPayment);
    }

    function buyPass(
        address passReceiver,
        uint256 paymentPeriod,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public returns (uint256) {
        processPayment(paymentPeriod);
        semaphoreVerifier.verifyProof(
            proof, [
                root, 
                nullifierHash, 
                hashToField(abi.encodePacked(msg.sender)), 
                externalNullifierHash
            ]
        );
        passesCount++;
        passId[passReceiver] = passesCount;
        passTillTimestamp[passReceiver] = block.timestamp + paymentPeriod * periodSeconds;
        return passesCount;
    }

    function extendPass(
        address passHolder,
        uint256 paymentPeriod
    ) public {
        if (passId[passHolder] == 0) {
            revert NotPassHolder(passHolder);
        }
        processPayment(paymentPeriod);
        passTillTimestamp[passHolder] += paymentPeriod * periodSeconds;
    }

    function validatePass(address passHolder) public view returns (bool) {
        if (passId[passHolder] == 0) {
            revert NotPassHolder(passHolder);
        }
        if (block.timestamp > passTillTimestamp[passHolder]) {
            revert PassExpired(passHolder, passTillTimestamp[passHolder]);
        }
        return true;
    }

}
