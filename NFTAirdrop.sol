// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTAirdrop {
    address public nftContract;
    address public owner;
    mapping(address => bool) public hasClaimed;

    event AirdropClaimed(address indexed claimant, uint256 tokenId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(address _nftContract) {
        nftContract = _nftContract;
        owner = msg.sender;
    }

    function claimAirdrop(uint256 tokenId) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not NFT owner");
        hasClaimed[msg.sender] = true;
        (bool success, ) = msg.sender.call{value: 0.001 ether}("");
        require(success, "Airdrop failed");
        emit AirdropClaimed(msg.sender, tokenId);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    receive() external payable {}
}
