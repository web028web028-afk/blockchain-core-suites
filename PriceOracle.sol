// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceOracle {
    address public owner;
    mapping(address => uint256) public tokenPrices;
    mapping(address => bool) public authorizedFeeds;

    event PriceUpdated(address indexed token, uint256 newPrice);
    event FeedAuthorized(address indexed feed, bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedFeeds[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedFeeds[msg.sender] = true;
    }

    function setAuthorizedFeed(address feed, bool status) external onlyOwner {
        authorizedFeeds[feed] = status;
        emit FeedAuthorized(feed, status);
    }

    function updatePrice(address token, uint256 newPrice) external onlyAuthorized {
        require(newPrice > 0, "Invalid price");
        tokenPrices[token] = newPrice;
        emit PriceUpdated(token, newPrice);
    }

    function getPrice(address token) external view returns (uint256) {
        return tokenPrices[token];
    }
}
