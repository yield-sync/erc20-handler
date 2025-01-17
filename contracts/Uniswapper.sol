// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol"; // For DEX like Uniswap

import { IERC20Handler } from "./interface/IERC20Handler.sol";


contract ERC20Converter is
	Ownable,
	IERC20Handler
{
	IUniswapV2Router02 public uniswapRouter;

	// Token the user will deposit
	address public depositToken;

	// Token the user will get in return (after conversion)
	address public convertedToken;

	// Token to return during withdrawal (can be same as `depositToken` or another token)
	address public convertedBackToken;


	constructor(
		address _depositToken,
		address _convertedToken,
		address _uniswapRouter
	) {
		depositToken = _depositToken;
		convertedToken = _convertedToken;
		convertedBackToken = _depositToken; // Set withdrawal token as original token by default
		uniswapRouter = IUniswapV2Router02(_uniswapRouter);
	}


	/// @inheritdoc IERC20Handler
	function utilizedERC20Deposit(address _from, address _utilizedERC20, uint256 _utilizedERC20Amount)
		external
		override
	{
		/**
		* Deposit function: Converts deposited ERC20 to the converted token
		*/
		require(_utilizedERC20 == depositToken, "Only deposit token can be used");

		// Transfer ERC20 from sender to this contract
		IERC20(depositToken).transferFrom(_from, address(this), _utilizedERC20Amount);

		// Convert the deposited ERC20 to another token (using Uniswap in this case)
		uint256 amountToSwap = _utilizedERC20Amount;
		IERC20(depositToken).approve(address(uniswapRouter), amountToSwap);

		address[] memory path = new address[](2);

		path[0] = depositToken;
		path[1] = convertedToken;

		// Perform the token conversion via Uniswap
		uniswapRouter.swapExactTokensForTokens(
			amountToSwap,
			0, // Set to 0 to accept any amount (or specify slippage tolerance)
			path,
			address(this),
			block.timestamp
		);

		// Deposit the converted tokens into this contract
		uint256 convertedAmount = IERC20(convertedToken).balanceOf(address(this));
		IERC20(convertedToken).transfer(_from, convertedAmount); // Return the converted tokens to the sender (optional)
	}

	// Withdraw function: Converts the token back to the original token
	function utilizedERC20Withdraw(address _to, address _utilizedERC20, uint256 _utilizedERC20Amount) external override {
		require(_utilizedERC20 == convertedBackToken, "Only converted back token can be used");

		// Check if there are enough funds in the contract
		uint256 contractBalance = IERC20(convertedToken).balanceOf(address(this));
		require(contractBalance >= _utilizedERC20Amount, "Insufficient funds for withdrawal");

		// Convert the withdrawn token back to the original token (using Uniswap)
		uint256 amountToSwap = _utilizedERC20Amount;
		IERC20(convertedToken).approve(address(uniswapRouter), amountToSwap);

		address[] memory path = new address[](2);

		path[0] = convertedToken;
		path[1] = depositToken;

		// Perform the token conversion via Uniswap
		uniswapRouter.swapExactTokensForTokens(
			amountToSwap,
			0, // Set to 0 to accept any amount (or specify slippage tolerance)
			path,
			address(this),
			block.timestamp
		);

		// Transfer the original deposit token back to the user
		uint256 amountToReturn = IERC20(depositToken).balanceOf(address(this));
		IERC20(depositToken).transfer(_to, amountToReturn);
	}


	// Implement the required methods from IERC20Handler interface
	function utilizedERC20TotalBalance(address _utilizedERC20)
		external
		view
		override
		returns (uint256 utilizedERC20Amount_)
	{
		if (_utilizedERC20 == depositToken) {
			return IERC20(depositToken).balanceOf(address(this));
		} else if (_utilizedERC20 == convertedToken) {
			return IERC20(convertedToken).balanceOf(address(this));
		}
		return 0;
	}

	// Add a function to update the router address (for upgrading or switching DEX)
	function updateUniswapRouter(address newRouter) external onlyOwner {
		uniswapRouter = IUniswapV2Router02(newRouter);
	}

	// Allow owner to set deposit and withdrawal tokens
	function setTokens(address _depositToken, address _convertedToken) external onlyOwner {
		depositToken = _depositToken;
		convertedToken = _convertedToken;
	}
}
