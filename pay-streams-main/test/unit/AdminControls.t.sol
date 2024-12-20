// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";

contract PayStreamsAdminControlsTest is GlobalHelper {
    function test_setFeeInBasisPointsFailsIfFeeIsGreaterThan10000() public {
        uint16 newFee = 10_001;

        vm.expectRevert(abi.encodeWithSelector(IPayStreams.PayStreams__InvalidFeeInBasisPoints.selector, newFee));
        _setFee(newFee);
    }

    function test_setFeeInBasisPoints() public {
        uint16 newFee = 100; // 1%

        _setFee(newFee);

        assertEq(stream.getFeeInBasisPoints(), newFee);
    }

    function test_setFeeInBasisPointsEmitsvent() public {
        uint16 newFee = 100; // 1%

        vm.expectEmit(true, true, true, true);
        emit IPayStreams.FeeInBasisPointsSet(deployer, newFee);
        _setFee(newFee);

        assertEq(stream.getFeeInBasisPoints(), newFee);
    }

    function test_setGasLimitForHooksFailsIfGasLimitIsZero() public {
        uint256 newGasLimit = 0;

        vm.expectRevert(IPayStreams.PayStreams__GasLimitZero.selector);
        _setGasLimitForHooks(newGasLimit);
    }

    function test_setGasLimitForHooks() public {
        uint256 newGasLimit = 1_000_000;

        _setGasLimitForHooks(newGasLimit);

        assertEq(stream.getGasLimitForHooks(), newGasLimit);
    }

    function test_setGasLimitForHooksEmitsEvent() public {
        uint256 newGasLimit = 1_000_000;

        vm.expectEmit(true, true, true, true);
        emit IPayStreams.GasLimitForHooksSet(deployer, newGasLimit);
        _setGasLimitForHooks(newGasLimit);

        assertEq(stream.getGasLimitForHooks(), newGasLimit);
    }

    function test_collectFeesFromStreamFailsIfFeeAmountIsZero() public {
        uint256 feeAmountToCollect = 100e6;

        vm.startPrank(deployer);
        vm.expectRevert(IPayStreams.PayStreams__InsufficientCollectedFees.selector);
        stream.collectFees(address(token), feeAmountToCollect, deployer);
        vm.stopPrank();
    }

    function test_collectFeesFromStream() public {
        uint16 newFee = 100; // 1%

        _setFee(newFee);

        bytes32 streamHash = _createTestStream();
        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        _warpBy(streamData.duration);
        stream.collectFundsFromStream(streamHash);

        uint256 expectedFeeAmount = (streamData.amount * newFee) / BPS;
        assertEq(token.balanceOf(address(stream)), expectedFeeAmount);

        vm.startPrank(deployer);
        stream.collectFees(address(token), expectedFeeAmount, deployer);
        vm.stopPrank();
        assertEq(token.balanceOf(address(deployer)), expectedFeeAmount);
        assertEq(token.balanceOf(address(stream)), 0);
    }

    function test_collectFeesFromStreamEmitsEvent() public {
        uint16 newFee = 100; // 1%

        _setFee(newFee);

        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        _mintAndApprove(streamData.amount);
        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        _warpBy(streamData.duration);
        stream.collectFundsFromStream(streamHash);

        uint256 expectedFeeAmount = (streamData.amount * newFee) / BPS;
        assertEq(token.balanceOf(address(stream)), expectedFeeAmount);

        vm.startPrank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.FeesCollected(streamData.token, expectedFeeAmount, deployer);
        stream.collectFees(address(token), expectedFeeAmount, deployer);
        vm.stopPrank();
    }
}
