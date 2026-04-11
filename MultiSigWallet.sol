// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    address[] public owners;
    uint256 public requiredConfirmations;
    mapping(address => bool) public isOwner;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public transactionConfirmations;

    event Deposit(address indexed sender, uint256 value);
    event TransactionSubmitted(uint256 indexed txId);
    event TransactionConfirmed(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Tx already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required");
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredConfirmations = _required;
    }

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256) {
        uint256 txId = transactions.length;
        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0
        }));
        emit TransactionSubmitted(txId);
        return txId;
    }

    function confirmTransaction(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId) {
        require(!transactionConfirmations[txId][msg.sender], "Already confirmed");
        Transaction storage tx = transactions[txId];
        transactionConfirmations[txId][msg.sender] = true;
        tx.confirmations += 1;
        emit TransactionConfirmed(txId, msg.sender);
        if (tx.confirmations >= requiredConfirmations) {
            executeTransaction(txId);
        }
    }

    function executeTransaction(uint256 txId) internal txExists(txId) notExecuted(txId) {
        Transaction storage tx = transactions[txId];
        require(tx.confirmations >= requiredConfirmations, "Not enough confirmations");
        (bool success, ) = tx.to.call{value: tx.value}(tx.data);
        require(success, "Tx failed");
        tx.executed = true;
        emit TransactionExecuted(txId);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
