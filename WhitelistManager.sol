// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WhitelistManager {
    address public owner;
    mapping(address => bool) public whitelist;
    uint256 public whitelistCount;

    event Whitelisted(address indexed account);
    event Unwhitelisted(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addToWhitelist(address account) external onlyOwner {
        require(!whitelist[account], "Already whitelisted");
        whitelist[account] = true;
        whitelistCount++;
        emit Whitelisted(account);
    }

    function batchAddWhitelist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!whitelist[accounts[i]]) {
                whitelist[accounts[i]] = true;
                whitelistCount++;
                emit Whitelisted(accounts[i]);
            }
        }
    }

    function removeFromWhitelist(address account) external onlyOwner {
        require(whitelist[account], "Not whitelisted");
        whitelist[account] = false;
        whitelistCount--;
        emit Unwhitelisted(account);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return whitelist[account];
    }
}
