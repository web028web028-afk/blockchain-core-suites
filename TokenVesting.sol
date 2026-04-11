// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenVesting {
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 vestingDuration;
    }

    mapping(address => VestingSchedule) public vestingSchedules;
    address public immutable token;
    address public owner;

    event VestingCreated(address indexed beneficiary, uint256 totalAmount);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token) {
        token = _token;
        owner = msg.sender;
    }

    function createVestingSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 _startTime,
        uint256 _cliffDuration,
        uint256 _vestingDuration
    ) external onlyOwner {
        require(vestingSchedules[beneficiary].totalAmount == 0, "Existing schedule");
        vestingSchedules[beneficiary] = VestingSchedule(
            totalAmount,
            0,
            _startTime,
            _cliffDuration,
            _vestingDuration
        );
        emit VestingCreated(beneficiary, totalAmount);
    }

    function calculateReleasableAmount(address beneficiary) public view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary];
        if (block.timestamp < schedule.startTime + schedule.cliffDuration) return 0;
        if (block.timestamp >= schedule.startTime + schedule.vestingDuration) {
            return schedule.totalAmount - schedule.releasedAmount;
        }
        uint256 elapsedTime = block.timestamp - schedule.startTime;
        uint256 vestedAmount = (schedule.totalAmount * elapsedTime) / schedule.vestingDuration;
        return vestedAmount - schedule.releasedAmount;
    }

    function releaseTokens() external {
        uint256 amount = calculateReleasableAmount(msg.sender);
        require(amount > 0, "No tokens to release");
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        schedule.releasedAmount += amount;
        (bool success, ) = token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount));
        require(success, "Transfer failed");
        emit TokensReleased(msg.sender, amount);
    }
}
