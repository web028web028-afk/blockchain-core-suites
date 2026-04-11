// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GovernanceProposal {
    struct Proposal {
        address proposer;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    Proposal[] public proposals;
    address public governanceToken;
    uint256 public votingPeriod = 7 days;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed id, string description);
    event VoteCast(uint256 indexed id, address voter, bool support);
    event ProposalExecuted(uint256 indexed id);

    constructor(address _govToken) {
        governanceToken = _govToken;
    }

    function createProposal(string calldata description) external returns (uint256) {
        uint256 id = proposals.length;
        proposals.push(Proposal({
            proposer: msg.sender,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp + votingPeriod,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        }));
        emit ProposalCreated(id, description);
        return id;
    }

    function castVote(uint256 id, bool support) external {
        require(id < proposals.length, "Invalid proposal");
        Proposal storage prop = proposals[id];
        require(block.timestamp < prop.endTime, "Voting ended");
        require(!hasVoted[id][msg.sender], "Already voted");
        hasVoted[id][msg.sender] = true;
        uint256 balance = getVotingPower(msg.sender);
        if (support) prop.forVotes += balance;
        else prop.againstVotes += balance;
        emit VoteCast(id, msg.sender, support);
    }

    function getVotingPower(address voter) internal view returns (uint256) {
        (bool success, bytes memory data) = governanceToken.staticcall(abi.encodeWithSignature("balanceOf(address)", voter));
        return success ? abi.decode(data, (uint256)) : 0;
    }

    function executeProposal(uint256 id) external {
        require(id < proposals.length, "Invalid proposal");
        Proposal storage prop = proposals[id];
        require(block.timestamp >= prop.endTime, "Voting active");
        require(!prop.executed, "Already executed");
        require(prop.forVotes > prop.againstVotes, "Rejected");
        prop.executed = true;
        emit ProposalExecuted(id);
    }
}
