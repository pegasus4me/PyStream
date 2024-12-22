// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";

import { PaymentSplitterVault } from "../vaults/PaymentSplitterVault.sol";

contract DeployPayStreams is Script {
    address public stream;
    address[] public recipients;
    uint256[] public weights;

    function run() external returns (address) {
        /// @dev Use correct addresses here. These are just placeholders
        stream = 0xfD3c782Ae7Ab6950409C65ba839349F5C0B32f19;
        recipients.push(0xa15C94e0b133111878EA3256aBd5dF22E50B7240);
        recipients.push(0x54D946760093fd5756c3EA4b9CCAE047c0ad4411);
        weights.push(70);
        weights.push(30);

        vm.startBroadcast();
        PaymentSplitterVault vault = new PaymentSplitterVault(stream, recipients, weights);
        vm.stopBroadcast();

        return address(vault);
    }
}
