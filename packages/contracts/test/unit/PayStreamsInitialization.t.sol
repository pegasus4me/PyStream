// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { PayStreams } from "../../src/PayStreams.sol";
import { GlobalHelper } from "../utils/GlobalHelper.sol";

contract PayStreamsInitializationTest is GlobalHelper {
    function test_deploymentFailsIfFeeAmountIsGreaterThan10000() public {
        uint16 invalidFee = 10_001;
        uint256 gasLimitForHooks = 100_000;

        vm.startPrank(deployer);
        vm.expectRevert(abi.encodeWithSelector(IPayStreams.PayStreams__InvalidFeeInBasisPoints.selector, invalidFee));
        new PayStreams(invalidFee, gasLimitForHooks);
        vm.stopPrank();
    }

    function test_checkFee() public view {
        assertEq(stream.getFeeInBasisPoints(), fee);
    }

    function test_checkGasLimitForHooks() public view {
        assertEq(stream.getGasLimitForHooks(), gasLimitForHooks);
    }
}
