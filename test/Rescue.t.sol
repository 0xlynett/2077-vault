// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Rescue} from "src/Rescue.sol";
import {SafeTestLib, SafeTestTools, SafeInstance} from "safe-tools/SafeTestTools.sol";
import {ISafe} from "@safe-global/safe-smart-account/contracts/interfaces/ISafe.sol";

contract CounterTest is Test, SafeTestTools {
    using SafeTestLib for SafeInstance;
    Rescue public rescue;
    SafeInstance public safeInstance;

    function setUp() public {
        safeInstance = _setupSafe();
        rescue = new Rescue(
            address(this),
            address(safeInstance.safe),
            address(safeInstance.safe)
        );
        safeInstance.enableModule(address(rescue));
    }

    function testRescue() public {
        ISafe s = ISafe(safeInstance.safe);
        address[] memory owners = s.getOwners();

        assertEq(owners.length, 3); // if your length is not length

        rescue.rescue();

        address[] memory ownersAfter = s.getOwners();
        assertEq(ownersAfter.length, 1);
        assertEq(ownersAfter[0], address(this));
    }
}
