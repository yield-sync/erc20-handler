// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { IERC20Handler } from "./interface/IERC20Handler.sol";

/**
* @notice This contract holds any sent ERC20 tokens, and only the owner can withdraw them.
*/
contract Holder is
	ReentrancyGuard,
	IERC20Handler
{
	address public immutable OWNER;


	constructor (address _owner)
	{
		OWNER = _owner;
	}


	function _onlyOwner()
		internal
		view
	{
		require(OWNER == msg.sender, "!(OWNER == msg.sender)");
	}

	modifier onlyOwner()
	{
		_onlyOwner();

		_;
	}


	/// @inheritdoc IERC20Handler
	function utilizedERC20TotalBalance(address _utilizedERC20)
		public
		view
		override
		returns (uint256 utilizedERC20TotalAmount_)
	{
		return IERC20(_utilizedERC20).balanceOf(address(this));
	}


	/// @inheritdoc IERC20Handler
	function utilizedERC20Deposit(address _from, address _utilizedERC20, uint256 _utilizedERC20Amount)
		public
		override
		nonReentrant()
		onlyOwner()
	{
		IERC20(_utilizedERC20).transferFrom(_from, address(this), _utilizedERC20Amount);
	}

	/// @inheritdoc IERC20Handler
	function utilizedERC20Withdraw(address _to, address _utilizedERC20, uint256 _utilizedERC20Amount)
		public
		override
		nonReentrant()
		onlyOwner()
	{
		IERC20(_utilizedERC20).transfer(_to, _utilizedERC20Amount);
	}
}
