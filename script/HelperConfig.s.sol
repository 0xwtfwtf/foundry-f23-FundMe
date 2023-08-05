//SPDX License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;  
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } 
        
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
        }
    

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    
        return sepoliaConfig;
        }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } 
        //if we've already deployed a price feed, just return that instead of deploying a new one
        //else deploy one
        
        else {
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        
        return anvilConfig;}    
        
    }
}

//this file deploys mocks when we're on local anvil chain
//if we're on a local anvil chain use the correct address for that
//otherwise use the correct address for mainnet
//if you have a bunch of networks and you need a bunch of info for each one (eg, price feed, decimals) create a custom type struct
//steps to an another network: spin up app on alchemy, add the rpc url to .env file, modify the constructor (get blockchain id), then add a get[_]Config function with the same syntax as above
//different with local blockchain anvil...on anvil we have to deploy the mock k first and then get the addresses