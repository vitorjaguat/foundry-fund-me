// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr('testUser'); // Create a unique address for testing

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Sepolia ETH/USD price feed address
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run(); // Deploy the contract using the script
        console.log("FundMe contract deployed at:", address(fundMe));
    }

    function testMinimumDollarIsFive() view public {
     assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD should be 5 USD in wei");
    }

    function testOwnerIsMsgSender() view public {
        console.log("Owner address:", fundMe.getOwner());
        console.log("Deployer address:", address(this));
        console.log("Message sender address:", msg.sender);
        assertEq(fundMe.getOwner(), msg.sender, "Owner should be the deployer of the contract");
    }

    function testPriceFeedVersionIsAccurate() view public {
        uint256 version = fundMe.getVersion();
        console.log("Price feed version:", version);
        assertEq(version, 4, "Price feed version should be 4.");
    }

    function testFundFailsWithoutEnoughEth() public payable {
        vm.expectRevert();
        fundMe.fund{value: 1 wei}();
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, 20 ether);
        fundMe.fund{value: 10 ether}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18, "Amount funded should be 10 ETH in wei");
        

    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "First funder should be USER's address");
    }

    function testOnlyOwnerCanWithdraw() public funded {
        uint256 balance1 = address(fundMe).balance;
        console.log('Contract Balance: ', balance1);
        assertGe(address(fundMe).balance, 10 ether, "Balance should be at least 10 ETH");

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();

    }

    function testWithdraw() public funded {
        //Arrange (set up the test)
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        console.log('Contract Balance before: ', startingFundMeBalance);
        
        // Act - Perform the withdrawal (as the owner)
        vm.prank(fundMe.getOwner()); // Use the actual owner address
        fundMe.withdraw();
        
        // Assert - Check the results
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        
        console.log('Contract Balance after: ', endingFundMeBalance);
        
        assertEq(endingFundMeBalance, 0, "Contract should have 0 balance after withdrawal");
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance, "Owner should receive all funds");
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), 20 ether); // this forge-std function is the same as calling vm.prank then vm.deal
            fundMe.fund{value: 10 ether}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner()); // an alternative way to activate vm.prank (gives more control)
        fundMe.withdraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), 20 ether); // this forge-std function is the same as calling vm.prank then vm.deal
            fundMe.fund{value: 10 ether}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner()); // an alternative way to activate vm.prank (gives more control)
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}