// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Rescue} from "src/Rescue.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address safe = 0x825001aC81d9348F71f2dADd717335aC0AB4a9FE;
        address r = address(new Rescue(msg.sender, safe, safe));
        vm.stopBroadcast();
        console.log(r);
    }
}
