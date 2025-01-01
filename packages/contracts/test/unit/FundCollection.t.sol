// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";
import { TestVault } from "../utils/TestVault.sol";

contract FundCollectionTest is GlobalHelper {
    function test_fundCollectionFromStreamFailsIfStreamHasNotStartedYet() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        bytes32 streamHash = stream.getStreamHash(streamData.streamer, streamData.recipient, streamData.token, tag);
        streamData.startingTimestamp = block.timestamp + 1 minutes;

        vm.startPrank(streamer);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        vm.startPrank(recipient);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPayStreams.PayStreams__StreamHasNotStartedYet.selector, streamHash, streamData.startingTimestamp
            )
        );
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionFromStreamFailsIfAmountToCollectIsZero() public {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        bytes32 streamHash = stream.getStreamHash(streamData.streamer, streamData.recipient, streamData.token, tag);

        vm.startPrank(streamer);
        stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        vm.startPrank(recipient);
        vm.expectRevert(IPayStreams.PayStreams__ZeroAmountToCollect.selector);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionMidWayThroughStream() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration / 2);

        vm.startPrank(recipient);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();

        uint256 feeAmount = 0;
        uint256 expectedAmountToCollect = amount / 2;
        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);
        uint256 actualFeeCollected = stream.getCollectedFees(streamData.token);

        assertEq(streamData.totalStreamed, expectedAmountToCollect);
        assertEq(actualFeeCollected, feeAmount);
        assertEq(IERC20(token).balanceOf(recipient), expectedAmountToCollect);
    }

    function test_fundCollectionForAnEndedStream() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration);

        vm.startPrank(recipient);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();

        uint256 feeAmount = 0;
        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);
        uint256 actualFeeCollected = stream.getCollectedFees(streamData.token);

        assertEq(streamData.totalStreamed, amount);
        assertEq(actualFeeCollected, feeAmount);
        assertEq(IERC20(token).balanceOf(recipient), amount);
    }

    function test_fundCollectionWithFees() public {
        uint16 newFee = 100;

        _setFee(newFee);

        bytes32 streamHash = _createTestStream();
        _warpBy(duration);

        uint256 feeAmount = amount * newFee / BPS;
        uint256 expectedAmountToCollect = amount - feeAmount;

        vm.startPrank(recipient);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();

        IPayStreams.StreamData memory streamData = stream.getStreamData(streamHash);
        uint256 actualFeeCollected = stream.getCollectedFees(streamData.token);

        assertEq(streamData.totalStreamed, expectedAmountToCollect + feeAmount);
        assertEq(actualFeeCollected, feeAmount);
        assertEq(IERC20(token).balanceOf(recipient), expectedAmountToCollect);
    }

    function test_fundCollectionEmitsEvent() public {
        bytes32 streamHash = _createTestStream();
        _warpBy(duration);

        uint256 feeAmount = 0;

        vm.startPrank(recipient);
        vm.expectEmit(true, true, true, true);
        emit IPayStreams.FundsCollectedFromStream(streamHash, amount, feeAmount);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionWithBeforeFundsCollectedHookInvokedOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeFundsCollected = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        token.mint(address(vault), amount);
        vm.startPrank(streamer);
        vault.approve(address(token), address(stream), amount);
        vm.stopPrank();
        _warpBy(duration);

        uint256 feeAmount = 0;

        vm.startPrank(recipient);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeFundsCollected(streamHash, amount, feeAmount);
        emit IPayStreams.FundsCollectedFromStream(streamHash, amount, feeAmount);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionWithBeforeFundsCollectedHookInvokedOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callBeforeFundsCollected = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        _warpBy(duration);

        uint256 feeAmount = 0;

        vm.startPrank(recipient);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledBeforeFundsCollected(streamHash, amount, feeAmount);
        emit IPayStreams.FundsCollectedFromStream(streamHash, amount, feeAmount);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionWithAfterFundsCollectedHookInvokedOnStreamerVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(streamer);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterFundsCollected = true;

        vm.startPrank(streamer);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        token.mint(address(vault), amount);
        vm.startPrank(streamer);
        vault.approve(address(token), address(stream), amount);
        vm.stopPrank();
        _warpBy(duration);

        uint256 feeAmount = 0;

        vm.startPrank(recipient);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterFundsCollected(streamHash, amount, feeAmount);
        emit IPayStreams.FundsCollectedFromStream(streamHash, amount, feeAmount);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }

    function test_fundCollectionWithAfterFundsCollectedHookInvokedOnRecipientVault() public {
        bytes32 streamHash = _createTestStream();

        TestVault vault = _setUpVault(recipient);
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        hookConfig.callAfterFundsCollected = true;

        vm.startPrank(recipient);
        stream.setVaultAndHookConfig(streamHash, address(vault), hookConfig);
        vm.stopPrank();

        _warpBy(duration);

        uint256 feeAmount = 0;

        vm.startPrank(recipient);
        vm.expectEmit(true, true, true, true);
        emit TestVault.CalledAfterFundsCollected(streamHash, amount, feeAmount);
        emit IPayStreams.FundsCollectedFromStream(streamHash, amount, feeAmount);
        stream.collectFundsFromStream(streamHash);
        vm.stopPrank();
    }
}
