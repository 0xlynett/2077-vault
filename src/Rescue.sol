// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Module} from "@gnosis-guild/zodiac/contracts/core/Module.sol";
import {Enum} from "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import {ISafe} from "@safe-global/safe-smart-account/contracts/interfaces/ISafe.sol";
import {IOwnerManager} from "@safe-global/safe-smart-account/contracts/interfaces/IOwnerManager.sol";

/// @title Rescue
/// @author L3 (for 2077 Collective)
/// A module that can be called at any time by the owner to set the safe's
/// signers to the owner in case the existing signers are incapacitated
/// or unavailable in some way. The owner should be another Safe, but may
/// not be.
contract Rescue is Module {
    constructor(address _owner, address _avatar, address _target) {
        setUp(abi.encode(_owner, _avatar, _target));
    }

    function setUp(bytes memory initializeParams) public virtual override initializer {
        (address _owner, address _avatar, address _target) = abi.decode(initializeParams, (address, address, address));
        __Ownable_init(_owner);
        require(_avatar != address(0), "Avatar cannot be zero address");
        require(_target != address(0), "Target cannot be zero address");
        setAvatar(_avatar);
        setTarget(_target);
    }

    function rescue() public onlyOwner {
        ISafe safe = ISafe(target);
        address[] memory owners = safe.getOwners();

        // Thanks for the code!
        // https://github.com/5afe/CandideWalletContracts/blob/113d3c059e039e332637e8f686d9cbd505f1e738/contracts/modules/social_recovery/SocialRecoveryModule.sol
        for (uint256 i = (owners.length - 1); i > 0; --i) {
            require(
                exec(
                    target,
                    0,
                    abi.encodeCall(IOwnerManager.removeOwner, (owners[i - 1], owners[i], 1)),
                    Enum.Operation.Call
                ),
                "Owner removal failed"
            );
        }

        require(
            exec(
                target,
                0,
                abi.encodeCall(IOwnerManager.swapOwner, (address(0x1), owners[0], owner())),
                Enum.Operation.Call
            ),
            "Owner add failed"
        );
    }
}
