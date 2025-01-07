require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "hardhat-contract-sizer";


const accounts: string[] = [`0x${process.env.PRIVATE_KEY}`];
const oneGwei: number = 1000000000;

export default {
	etherscan: {
		apiKey: {
			mainnet: process.env.ETHERSCAN_API_KEY,
			goerli: process.env.ETHERSCAN_API_KEY,
			optimisticEthereum: process.env.OPTIMISTIC_ETHERSCAN_API_KEY,
			optimisticGoerli: process.env.OPTIMISTIC_ETHERSCAN_API_KEY,
			sepolia: process.env.ETHERSCAN_API_KEY,
			"base-sepolia": process.env.SEPOLIA_BASE_API_KEY
		},
		customChains: [
			{
				network: "base-sepolia",
				chainId: 84532,
				urls: {
					apiURL: "https://api-sepolia.basescan.org/api",
					browserURL: "https://basescan.org",
				},
			},
		],
	},
	networks: {
		goerli: {
			url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
			accounts
		},
		ropsten: {
			url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
			accounts
		},
		mainnet: {
			url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
			accounts
		},
		optimism: {
			url: `https://mainnet.optimism.io`,
			accounts,
			gasPrice: 15000000,
			ovm: true
		},
		optimismgoerli: {
			url: `https://goerli.optimism.io`,
			accounts,
			gasPrice: 15000000
		},
		sepolia: {
			url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
			accounts,
			chainId: 11155111,
			gasPrice: oneGwei,
		},
		'base-mainnet': {
			url: 'https://mainnet.base.org',
			accounts,
			gasPrice: oneGwei,
		},
		'base-sepolia': {
			url: 'https://sepolia.base.org',
			accounts,
			chainId: 84532,
			gasPrice: oneGwei,
		},
		hardhat: {
			allowUnlimitedContractSize: true,
		},
	},
	paths: {
		sources: "./contracts",
	},
	solidity: "0.8.19",

	settings: {
		optimizer: {
			enabled: true,
			runs: 500,
		},
	}
} as HardhatUserConfig;
