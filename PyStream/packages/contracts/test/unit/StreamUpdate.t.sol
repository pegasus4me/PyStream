// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract StreamUpdateTest is GlobalHelper {
    function test_updatingStreamFailsIfCallerIsNotStreamCreator() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(recipient);
        vm.expectRevert(IPayStreams.PayStreams__Unauthorized.selector);
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }

    function test_updatingStreamFailsIfUpdateAmountIsLessThanTotalStreamedAmount() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(recipient);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();

        uint256 updatedAmount = amount / 2 - 1;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: false,
            updateDuration: false,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidUpdateParams.selector);
        stream.updateStream(streamHash, updatedAmount, 0, 0, false, updateConfig);
        vm.stopPrank();
    }

    function test_updatingStreamFailsIfUpdatedStartingTimestampIsLessThanBlockTimestamp() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        uint256 updatedStartingTimestamp = block.timestamp - 1;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: true,
            updateDuration: false,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidUpdateParams.selector);
        stream.updateStream(streamHash, 0, updatedStartingTimestamp, 0, false, updateConfig);
        vm.stopPrank();
    }

    function test_updatingStreamFailsIfUpdatedDurationIsZero() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedDuration = 0;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: false,
            updateDuration: true,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__InvalidUpdateParams.selector);
        stream.updateStream(streamHash, 0, 0, updatedDuration, false, updateConfig);
        vm.stopPrank();
    }

    function test_updatingStreamFailsIfStreamIsPaused() public {
        bytes32 streamHash = _createTestStream();

        vm.startPrank(streamer);
        stream.pauseStream(streamHash);
        vm.stopPrank();

        uint256 updatedDuration = 2 days;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: false,
            updateDuration: true,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        vm.expectRevert(IPayStreams.PayStreams__CannotUpdateWhenStreamPaused.selector);
        stream.updateStream(streamHash, 0, 0, updatedDuration, false, updateConfig);
        vm.stopPrank();
    }

    function test_updateStreamAmount() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedAmount = amount + 1;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: false,
            updateDuration: false,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        stream.updateStream(streamHash, updatedAmount, 0, 0, false, updateConfig);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.amount, updatedAmount);
    }

    function test_updateStreamStartingTimestamp() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedStartingTimestamp = block.timestamp + 1;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: true,
            updateDuration: false,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        stream.updateStream(streamHash, 0, updatedStartingTimestamp, 0, false, updateConfig);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.startingTimestamp, updatedStartingTimestamp);
    }

    function test_updateStreamDuration() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedDuration = 2 days;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: false,
            updateDuration: true,
            updateRecurring: false
        });

        vm.startPrank(streamer);
        stream.updateStream(streamHash, 0, 0, updatedDuration, false, updateConfig);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.duration, updatedDuration);
    }

    function test_updateStreamRecurring() public {
        bytes32 streamHash = _createTestStream();

        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: false,
            updateStartingTimestamp: false,
            updateDuration: false,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        stream.updateStream(streamHash, 0, 0, 0, updatedRecurring, updateConfig);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.recurring, updatedRecurring);
    }

    function test_updateAllStreamParams() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);

        assertEq(streamData.amount, updatedAmount);
        assertEq(streamData.startingTimestamp, updatedStartingTimestamp);
        assertEq(streamData.duration, updatedDuration);
        assertEq(streamData.recurring, updatedRecurring);
    }

    function test_updateStreamEmitsEvent() public {
        bytes32 streamHash = _createTestStream();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.StreamUpdated(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }

    function test_updateStreamWithBeforeStreamUpdatedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamUpdated = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamUpdated(streamHash);
        emit IPayStreams.StreamUpdated(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }

    function test_updateStreamWithBeforeStreamUpdatedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeStreamUpdated = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeStreamUpdated(streamHash);
        emit IPayStreams.StreamUpdated(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }

    function test_updateStreamWithAfterStreamUpdatedHookCalledOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamUpdated = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamUpdated(streamHash);
        emit IPayStreams.StreamUpdated(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }

    function test_updateStreamWithAfterStreamUpdatedHookCalledOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterStreamUpdated = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        uint256 updatedAmount = amount + 1;
        uint256 updatedStartingTimestamp = block.timestamp + 1;
        uint256 updatedDuration = 2 hours;
        bool updatedRecurring = true;

        IPayStreams.UpdateConfig memory updateConfig = IPayStreams.UpdateConfig({
            updateAmount: true,
            updateStartingTimestamp: true,
            updateDuration: true,
            updateRecurring: true
        });

        vm.startPrank(streamer);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterStreamUpdated(streamHash);
        emit IPayStreams.StreamUpdated(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        stream.updateStream(
            streamHash, updatedAmount, updatedStartingTimestamp, updatedDuration, updatedRecurring, updateConfig
        );
        vm.stopPrank();
    }
}
