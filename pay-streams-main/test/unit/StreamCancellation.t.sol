// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract StreamCancellationTest is GlobalHelper {
    function test_cancelStreamFailsIfCallerNotStreamCreator() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(recipient);
        vm.expectRevert(IPayStreams.PayStreams__Unauthorized.selector);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }

    function test_cancelStream() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(streamer);
        stream.cancelStream(streamHash);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.amount, 0);
    }

    function test_cancelStreamEmitsEvent() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.StreamCancelled(streamHash);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }

    function test_cancelStreamWithBeforeStreamClosedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamClosed = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamClosed(streamHash);
        emit IPayStreams.StreamCancelled(streamHash);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }

    function test_cancelStreamWithBeforeStreamClosedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamClosed = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamClosed(streamHash);
        emit IPayStreams.StreamCancelled(streamHash);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }

    function test_cancelStreamWithAfterStreamClosedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamClosed = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamClosed(streamHash);
        emit IPayStreams.StreamCancelled(streamHash);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }

    function test_cancelStreamWithAfterStreamClosedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamClosed = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamClosed(streamHash);
        emit IPayStreams.StreamCancelled(streamHash);
        stream.cancelStream(streamHash);
        vm.stopPrank();
    }
}
