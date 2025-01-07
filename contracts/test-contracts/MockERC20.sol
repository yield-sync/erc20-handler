// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
 * @notice WARNING: This contract is ONLY for TESTING.
*/
contract MockERC20 is ERC20
{
	uint8 internal immutable _DECIMALS;


	function decimals()
		public
		view
		virtual
		override
		returns (uint8)
	{
        return _DECIMALS;
    }


	constructor (string memory _name, string memory _symbol, uint8 _decimals)
		ERC20(_name, _symbol)
	{
		_DECIMALS = _decimals;

		// Sent msg.sender 100m MOCKERC20 tokens
		_mint(msg.sender, 100_000_000 * (10 ** _decimals));
	}
}
