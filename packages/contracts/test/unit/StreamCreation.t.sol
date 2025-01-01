// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract StreamCreationTest is GlobalHelper {
    function test_streamCreationFailsIfStreamerIsNotMsgSender() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.streamer = deployer;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfRecipientIsAddressZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.recipient = address(0);

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfRecipientVaultIsNotAddressZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.recipientVault = address(1);

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfAmountToStreamIsZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.amount = 0;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfStartingTimestampIsLessThanCurrentTimestamp() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.startingTimestamp = block.timestamp - 1;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfStreamDurationIsZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.duration = 0;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfTotalStreamedAmountIsNotZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.totalStreamed = streamData.amount;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfPauseTimestampIsNotZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        streamData.lastPausedAt = 1;

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidStreamConfig.selector);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationFailsIfStreamAlreadyExists() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();

        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.expectRevert(abi.encodeWithSelector(IPayStreams.PayStreams__StreamAlreadyExists.selector, streamHash));
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationSucceeds() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();

        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        IPayStreams.StreamData memory actualStreamData = stream.getStreamData(streamHash);

        assertEq(actualStreamData.streamer, streamData.streamer);
        assertEq(actualStreamData.streamerVault, streamData.streamerVault);
        assertEq(actualStreamData.recipient, streamData.recipient);
        assertEq(actualStreamData.recipientVault, streamData.recipientVault);
        assertEq(actualStreamData.token, streamData.token);
        assertEq(actualStreamData.amount, streamData.amount);
        assertEq(actualStreamData.startingTimestamp, streamData.startingTimestamp);
        assertEq(actualStreamData.duration, streamData.duration);
        assertEq(actualStreamData.totalStreamed, streamData.totalStreamed);
        assertEq(actualStreamData.recurring, streamData.recurring);

        assertEq(stream.getStreamerStreamHashes(streamer)[0], streamHash);
        assertEq(stream.getRecipientStreamHashes(recipient)[0], streamHash);

        IPayStreams.HookConfig memory actualHookConfig = stream.getHookConfig(streamer, streamHash);

        assertEq(actualHookConfig.callAfterStreamCreated, hookConfig.callAfterStreamCreated);
        assertEq(actualHookConfig.callBeforeFundsCollected, hookConfig.callBeforeFundsCollected);
        assertEq(actualHookConfig.callAfterFundsCollected, hookConfig.callAfterFundsCollected);
        assertEq(actualHookConfig.callBeforeStreamUpdated, hookConfig.callBeforeStreamUpdated);
        assertEq(actualHookConfig.callAfterStreamUpdated, hookConfig.callAfterStreamUpdated);
        assertEq(actualHookConfig.callBeforeStreamClosed, hookConfig.callBeforeStreamClosed);
        assertEq(actualHookConfig.callAfterStreamClosed, hookConfig.callAfterStreamClosed);
    }

    function test_streamCreationEmitsEvent() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        bytes32 streamHash = stream.getStreamHash(streamData.streamer, streamData.recipient, streamData.token, tag);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.StreamCreated(streamHash);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationWithStreamerVaultSet() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        TestVault vault = _setUpVault(streamer);
        streamData.streamerVault = address(vault);

        vm.startPrank(streamer);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }

    function test_streamCreationWithVaultAndHooks() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        TestVault vault = _setUpVault(streamer);
        streamData.streamerVault = address(vault);
        hookConfig.callAfterStreamCreated = true;

        bytes32 streamHash = stream.getStreamHash(streamData.streamer, streamData.recipient, streamData.token, tag);

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamCreated(streamHash);
        emit IPayStreams.StreamCreated(streamHash);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();
    }
}
