import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, BigNumber, ContractFactory, Signer, VoidSigner } from "ethers";


describe("SimpleV1EMPStrategyInteractor", function () {
	let owner: Signer;
	let other: Signer;
	let token: Contract;
	let strategyInteractor: Contract;


	beforeEach(async () => {
		[owner, other] = await ethers.getSigners();

		// Deploy a mock ERC20 token for testing
		const MockERC20: ContractFactory = await ethers.getContractFactory("MockERC20");
		const SimpleV1EMPStrategyInteractor = await ethers.getContractFactory("SimpleV1EMPStrategyInteractor");

		token = await (await MockERC20.deploy("Mock A", "A", 18)).deployed();

		strategyInteractor = await SimpleV1EMPStrategyInteractor.deploy(await owner.getAddress());

		await strategyInteractor.deployed();
	});


	it("should set the correct owner", async () => {
		expect(await strategyInteractor.OWNER()).to.equal(await owner.getAddress());
	});


	describe("function utilizedERC20Deposit()", function () {
		describe("Expected Failure", function () {
			it("[auth] Should revert when unauthorized msg.sender calls..", async () => {
				const amount = ethers.utils.parseEther("10");

				// Approve tokens from other signer
				await token.connect(other).approve(strategyInteractor.address, amount);

				// Attempt to deposit from non-owner
				await expect(
					strategyInteractor.connect(other).utilizedERC20Deposit(await other.getAddress(), token.address, amount)
				).to.be.revertedWith(
					"!(OWNER == msg.sender)"
				);
			});
		});

		describe("Expected Success", function () {
			it("should allow the owner to deposit tokens", async () => {
				const amount = ethers.utils.parseEther("10");

				// Approve and deposit tokens
				await token.connect(owner).approve(strategyInteractor.address, amount);
				await strategyInteractor.utilizedERC20Deposit(await owner.getAddress(), token.address, amount);

				// Check contract balance
				const balance = await token.balanceOf(strategyInteractor.address);
				expect(balance).to.equal(amount);
			});
		});
	});

	describe("function utilizedERC20Deposit()", function () {
		describe("Expected Failure", function () {
			it("[auth] Should revert when unauthorized msg.sender calls..", async () => {
				const depositAmount = ethers.utils.parseEther("10");
				const withdrawAmount = ethers.utils.parseEther("5");

				// Deposit tokens
				await token.connect(owner).approve(strategyInteractor.address, depositAmount);
				await strategyInteractor.utilizedERC20Deposit(await owner.getAddress(), token.address, depositAmount);

				// Attempt to withdraw from non-owner
				await expect(
					strategyInteractor.connect(other).utilizedERC20Withdraw(
						await other.getAddress(),
						token.address,
						withdrawAmount
					)
				).to.be.revertedWith(
					"!(OWNER == msg.sender)"
				);
			});
		});

		describe("Expected Success", function () {
			it("should allow the owner to withdraw tokens", async () => {
				const depositAmount = ethers.utils.parseEther("10");
				const withdrawAmount = ethers.utils.parseEther("5");

				// Approve tokens and deposit
				await token.connect(owner).approve(strategyInteractor.address, depositAmount);

				await strategyInteractor.utilizedERC20Deposit(await owner.getAddress(), token.address, depositAmount);

				// Withdraw tokens
				await strategyInteractor.utilizedERC20Withdraw(await owner.getAddress(), token.address, withdrawAmount);

				// Check balances
				const contractBalance = await token.balanceOf(strategyInteractor.address);
				const ownerBalance = await token.balanceOf(await owner.getAddress());

				expect(contractBalance).to.equal(depositAmount.sub(withdrawAmount));

				expect(ownerBalance).to.equal(ethers.utils.parseEther("100000000").sub(depositAmount).add(withdrawAmount));
			});

			it("should return the correct total utilized ERC20 balance", async () => {
				const amount = ethers.utils.parseEther("10");

				// Deposit tokens
				await token.connect(owner).approve(strategyInteractor.address, amount);
				await strategyInteractor.utilizedERC20Deposit(await owner.getAddress(), token.address, amount);

				// Check utilized ERC20 balance
				const balance = await strategyInteractor.utilizedERC20TotalBalance(token.address);
				expect(balance).to.equal(amount);
			});
		});
	});
});
