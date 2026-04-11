// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingPool {
    address public rewardToken;
    uint256 public rewardRate;
    uint256 public totalStaked;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public userRewardDebt;
    mapping(address => uint256) public earnedRewards;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _rewardToken, uint256 _rewardRate) {
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    function updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            earnedRewards[account] = earned(account);
            userRewardDebt[account] = userStaked[account] * rewardPerTokenStored;
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalStaked;
    }

    function earned(address account) public view returns (uint256) {
        return (userStaked[account] * (rewardPerToken() - userRewardDebt[account])) / 1e18 + earnedRewards[account];
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount zero");
        updateReward(msg.sender);
        userStaked[msg.sender] += amount;
        totalStaked += amount;
        (bool success, ) = rewardToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), amount));
        require(success, "Stake failed");
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0 && userStaked[msg.sender] >= amount, "Invalid amount");
        updateReward(msg.sender);
        userStaked[msg.sender] -= amount;
        totalStaked -= amount;
        (bool success, ) = rewardToken.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount));
        require(success, "Unstake failed");
        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external {
        updateReward(msg.sender);
        uint256 reward = earnedRewards[msg.sender];
        require(reward > 0, "No reward");
        earnedRewards[msg.sender] = 0;
        (bool success, ) = rewardToken.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, reward));
        require(success, "Claim failed");
        emit RewardClaimed(msg.sender, reward);
    }
}
