// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts@5.1.0/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts@5.1.0/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts@5.1.0/token/ERC20/extensions/ERC20FlashMint.sol";
import {ERC20Pausable} from "@openzeppelin/contracts@5.1.0/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts@5.1.0/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts@5.1.0/access/Ownable.sol";

contract Nudex is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20FlashMint {
    // Address to receive the transaction fee
    address private _feeRecipient;

    // Transaction fee percentage (in basis points, e.g., 100 = 1%)
    uint256 private _transactionFee;

    // Anti-bot protection parameters
    mapping(address => bool) private _whitelistedAddresses;
    uint256 private _transferDelay; // Minimum time between transfers per address
    mapping(address => uint256) private _lastTransferTime;

    event FeeParametersUpdated(address indexed feeRecipient, uint256 transactionFee);
    event WhitelistUpdated(address indexed account, bool isWhitelisted);
    event TransferDelayUpdated(uint256 delay);

    constructor(address initialOwner, address initialFeeRecipient, uint256 initialTransactionFee)
        ERC20("Nudex", "NUD")
        Ownable(initialOwner)
        ERC20Permit("Nudex")
    {
        require(initialTransactionFee <= 10000, "Fee cannot exceed 100%");
        _feeRecipient = initialFeeRecipient;
        _transactionFee = initialTransactionFee;
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Update fee recipient and fee percentage
    function setFeeParameters(address newFeeRecipient, uint256 newTransactionFee) external onlyOwner {
        require(newTransactionFee <= 10000, "Fee cannot exceed 100%");
        _feeRecipient = newFeeRecipient;
        _transactionFee = newTransactionFee;
        emit FeeParametersUpdated(newFeeRecipient, newTransactionFee);
    }

    // Set transfer delay to prevent bot abuse
    function setTransferDelay(uint256 delay) external onlyOwner {
        _transferDelay = delay;
        emit TransferDelayUpdated(delay);
    }

    // Whitelist an address to bypass anti-bot protections
    function setWhitelistedAddress(address account, bool isWhitelisted) external onlyOwner {
        _whitelistedAddresses[account] = isWhitelisted;
        emit WhitelistUpdated(account, isWhitelisted);
    }

    // Get fee recipient
    function feeRecipient() external view returns (address) {
        return _feeRecipient;
    }

    // Get transaction fee percentage
    function transactionFee() external view returns (uint256) {
        return _transactionFee;
    }

    // Custom transfer function with fee logic and anti-bot protections
    function transferWithFee(address recipient, uint256 amount) public returns (bool) {
        require(!paused(), "Token transfers are paused");
        require(_whitelistedAddresses[msg.sender] || block.timestamp >= _lastTransferTime[msg.sender] + _transferDelay, "Transfer delay in effect");

        uint256 feeAmount = (amount * _transactionFee) / 10000;
        uint256 amountAfterFee = amount - feeAmount;

        if (feeAmount > 0 && _feeRecipient != address(0)) {
            super.transfer(_feeRecipient, feeAmount);
        }

        _lastTransferTime[msg.sender] = block.timestamp;
        return super.transfer(recipient, amountAfterFee);
    }

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
