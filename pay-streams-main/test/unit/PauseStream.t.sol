// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract PauseStreamTest is GlobalHelper {
    function test_pausingStreamFailsIfCallerNotStreamer() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(recipient);
        vm.expectRevert(IPayStreams.PayStreams__Unauthorized.selector);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pausingStreamFailsIfStreamHasNotStartedYet() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.startingTimestamp = block.timestamp + 1;
        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__CannotPauseStream.selector);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pausingStreamFailsIfANonRecurringStreamHasEnded() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration + 1);

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__CannotPauseStream.selector);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pausingStreamFailsIfAStreamIsAlreadyPaused() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.expectRevert(IPayStreams.PayStreams__CannotPauseStream.selector);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStream() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);
        (uint256 amountToCollect,) = stream.getAmountToCollectFromStreamAndFeeToPay(streamHash);

        assertEq(streamData.lastPausedAt, block.timestamp);
        assertEq(amountToCollect, amount / 2);

        _warpBy(duration / 2);

        (amountToCollect,) = stream.getAmountToCollectFromStreamAndFeeToPay(streamHash);

        assertEq(amountToCollect, amount / 2);
    }

    function test_pauseStreamEmitsEvent() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.StreamPaused(streamHash);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithBeforeStreamPausedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamPaused = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamPaused(streamHash);
        emit IPayStreams.StreamPaused(streamHash);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithBeforeStreamPausedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamPaused = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamPaused(streamHash);
        emit IPayStreams.StreamPaused(streamHash);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithAfterStreamPausedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamPaused = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamPaused(streamHash);
        emit IPayStreams.StreamPaused(streamHash);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }

    function test_pauseStreamWithAfterStreamPausedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamPaused = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamPaused(streamHash);
        emit IPayStreams.StreamPaused(streamHash);
        stream.pauseStream(streamHash);
        vm.stopPrank();
    }
}
