// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract UnPauseStreamTest is GlobalHelper {
    function test_unpausingStreamFailsIfCallerNotStreamer() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(recipient);
        vm.expectRevert(IPayStreams.PayStreams__Unauthorized.selector);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_unpausingStreamFailsIfStreamHasNotBeenPausedYet() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__NotPaused.selector);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_unPauseStream() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        stream.unPauseStream(streamHash);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);
        (uint256 amountToCollect,) = stream.getAmountToCollectFromStreamAndFeeToPay(streamHash);

        assertEq(streamData.startingTimestamp, block.timestamp - duration / 2);
        assertEq(streamData.lastPausedAt, 0);
        assertEq(amountToCollect, amount / 2);
    }

    function test_unPauseRecurringStream() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.recurring = true;
        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
        _warpBy(duration);

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration);

        vm.startPrank(streamer);
        stream.unPauseStream(streamHash);
        vm.stopPrank();

        streamData = stream.getStreamData(streamHash);
        (uint256 amountToCollect,) = stream.getAmountToCollectFromStreamAndFeeToPay(streamHash);

        assertEq(streamData.startingTimestamp, block.timestamp - duration);
        assertEq(streamData.lastPausedAt, 0);
        assertEq(amountToCollect, amount);
    }

    function test_unPauseStreamEmitsEvent() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.StreamUnPaused(streamHash);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_unPauseStreamWithBeforeStreamPausedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamUnPaused = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamUnPaused(streamHash);
        emit IPayStreams.StreamPaused(streamHash);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithBeforeStreamPausedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamUnPaused = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamUnPaused(streamHash);
        emit IPayStreams.StreamUnPaused(streamHash);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithAfterStreamPausedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamUnPaused = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamUnPaused(streamHash);
        emit IPayStreams.StreamUnPaused(streamHash);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithAfterStreamPausedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamUnPaused = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamUnPaused(streamHash);
        emit IPayStreams.StreamUnPaused(streamHash);
        stream.unPauseStream(streamHash);
        vm.stopPrank();
    }
}
