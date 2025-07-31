// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from '../src/FundMe.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script {
 function run() external returns (FundMe) {

   // Before startBroadcast, we can set up the environment: NOT a "real" transaction yet
   HelperConfig config = new HelperConfig();
   (address ethUsdPriceFeed) = config.activeNetworkConfig();

    vm.startBroadcast();
    FundMe fundMe = new FundMe(ethUsdPriceFeed); 
    vm.stopBroadcast();

    // Log the address of the deployed contract
    console.log("FundMe deployed to:", address(fundMe));
    return fundMe;
 }
}   