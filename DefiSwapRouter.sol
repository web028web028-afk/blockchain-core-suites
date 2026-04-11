// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DefiSwapRouter {
    address public owner;
    uint256 public feeRate = 25;
    address public feeReceiver;

    event Swapped(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event FeeUpdated(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _feeReceiver) {
        owner = msg.sender;
        feeReceiver = _feeReceiver;
    }

    function calculateFee(uint256 amount) internal view returns (uint256) {
        return (amount * feeRate) / 10000;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address pool
    ) external returns (uint256) {
        require(amountIn > 0, "Amount zero");
        uint256 fee = calculateFee(amountIn);
        uint256 swapAmount = amountIn - fee;
        IERC20(tokenIn).transferFrom(msg.sender, feeReceiver, fee);
        IERC20(tokenIn).transferFrom(msg.sender, pool, swapAmount);
        (bool success, bytes memory data) = pool.call(
            abi.encodeWithSignature("swap(address,address,uint256,address)", tokenIn, tokenOut, swapAmount, msg.sender)
        );
        require(success, "Swap failed");
        uint256 amountOut = abi.decode(data, (uint256));
        require(amountOut >= minAmountOut, "Slippage too high");
        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
        return amountOut;
    }

    function updateFee(uint256 newRate) external onlyOwner {
        require(newRate <= 100, "Fee too high");
        feeRate = newRate;
        emit FeeUpdated(newRate);
    }

    function updateFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "Zero address");
        feeReceiver = newReceiver;
    }
}
