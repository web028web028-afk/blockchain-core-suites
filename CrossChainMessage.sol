// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrossChainMessage {
    address public ccmGateway;
    address public owner;
    mapping(uint256 => bytes) public receivedMessages;
    uint256 public messageNonce;

    event MessageSent(uint256 indexed nonce, uint256 destChainId, bytes message);
    event MessageReceived(uint256 indexed nonce, bytes message);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyGateway() {
        require(msg.sender == ccmGateway, "Not gateway");
        _;
    }

    constructor(address _gateway) {
        ccmGateway = _gateway;
        owner = msg.sender;
    }

    function sendCrossChainMessage(uint256 destChainId, bytes calldata message) external {
        messageNonce++;
        (bool success, ) = ccmGateway.call(abi.encodeWithSignature(
            "sendMessage(uint256,uint256,bytes)",
            messageNonce,
            destChainId,
            message
        ));
        require(success, "CCM send failed");
        emit MessageSent(messageNonce, destChainId, message);
    }

    function receiveCrossChainMessage(uint256 nonce, bytes calldata message) external onlyGateway {
        receivedMessages[nonce] = message;
        emit MessageReceived(nonce, message);
    }

    function updateGateway(address newGateway) external onlyOwner {
        ccmGateway = newGateway;
    }
}
