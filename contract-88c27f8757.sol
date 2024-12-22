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
    constructor(address initialOwner)
        ERC20("Nudex", "NUD")
        Ownable(initialOwner)
        ERC20Permit("Nudex")
    {
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
