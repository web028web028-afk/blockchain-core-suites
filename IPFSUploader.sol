// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IPFSUploader {
    address public owner;
    mapping(address => string[]) public userCidList;
    mapping(string => address) public cidOwner;
    mapping(string => uint256) public cidUploadTime;

    event CIDUploaded(address indexed uploader, string cid, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function uploadCID(string calldata cid) external {
        require(bytes(cid).length > 0, "Empty CID");
        require(cidOwner[cid] == address(0), "CID exists");
        userCidList[msg.sender].push(cid);
        cidOwner[cid] = msg.sender;
        cidUploadTime[cid] = block.timestamp;
        emit CIDUploaded(msg.sender, cid, block.timestamp);
    }

    function getUserCIDCount(address user) external view returns (uint256) {
        return userCidList[user].length;
    }

    function getUserCIDAtIndex(address user, uint256 index) external view returns (string memory) {
        require(index < userCidList[user].length, "Invalid index");
        return userCidList[user][index];
    }

    function transferCIDOwnership(string calldata cid, address newOwner) external {
        require(cidOwner[cid] == msg.sender, "Not owner");
        require(newOwner != address(0), "Zero address");
        cidOwner[cid] = newOwner;
    }
}
