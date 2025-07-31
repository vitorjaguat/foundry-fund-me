// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    
    function setUp() external {

        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // Give the FundFundMe contract ETH since it's the one making the call
        vm.deal(address(fundFundMe), 1 ether);
        fundFundMe.fundFundMe(address(fundMe));

        // Check the funder BEFORE withdrawal (since withdraw resets the array)
        address funder = fundMe.getFunder(0);
        assertEq(funder, address(fundFundMe)); // The funder is the contract, not USER

        // Now withdraw as the owner
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Check that the contract balance is 0 after withdrawal
        assert(address(fundMe).balance == 0);
    }
}