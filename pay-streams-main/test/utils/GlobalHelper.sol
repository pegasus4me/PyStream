// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Test } from "forge-std/Test.sol";

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { PayStreams } from "../../src/PayStreams.sol";
import { MockToken } from "./MockToken.sol";
import { TestVault } from "./TestVault.sol";

contract GlobalHelper is Test {
    address public deployer;
    address public streamer;
    address public recipient;
    string public tokenName = "PayPal USD";
    string public tokenSymbol = "PYUSD";
    MockToken public token;

    uint16 public fee;
    uint256 public gasLimitForHooks;

    PayStreams public stream;

    /// @dev Example parameters for stream creation
    uint256 public amount = 100e6;
    uint256 public duration = 10 days;
    bool public recurring = false;

    uint16 public constant BPS = 10_000;

    function setUp() public {
        deployer = makeAddr("deployer");
        streamer = makeAddr("streamer");
        recipient = makeAddr("recipient");
        token = new MockToken(tokenName, tokenSymbol);

        gasLimitForHooks = 100_000;

        vm.startPrank(deployer);
        stream = new PayStreams(fee, gasLimitForHooks);
        vm.stopPrank();
    }

    function _createTestStream() internal returns (bytes32) {
        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        _mintAndApprove(streamData.amount);

        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        return streamHash;
    }

    function _getTestStreamCreationData()
        internal
        view
        returns (IPayStreams.StreamData memory, IPayStreams.HookConfig memory, string memory)
    {
        IPayStreams.StreamData memory streamData = IPayStreams.StreamData({
            streamer: streamer,
            streamerVault: address(0),
            recipient: recipient,
            recipientVault: address(0),
            token: address(token),
            amount: amount,
            startingTimestamp: block.timestamp,
            duration: duration,
            totalStreamed: 0,
            recurring: recurring,
            lastPausedAt: 0
        });
        IPayStreams.HookConfig memory hookConfig = _getBaseHookConfig();
        string memory tag = "test stream";

        return (streamData, hookConfig, tag);
    }

    function _getBaseHookConfig() internal pure returns (IPayStreams.HookConfig memory) {
        IPayStreams.HookConfig memory hookConfig = IPayStreams.HookConfig({
            callAfterStreamCreated: false,
            callBeforeFundsCollected: false,
            callAfterFundsCollected: false,
            callBeforeStreamUpdated: false,
            callAfterStreamUpdated: false,
            callBeforeStreamPaused: false,
            callAfterStreamPaused: false,
            callBeforeStreamUnPaused: false,
            callAfterStreamUnPaused: false,
            callBeforeStreamClosed: false,
            callAfterStreamClosed: false
        });

        return hookConfig;
    }

    function _setUpVault(address _for) internal returns (TestVault) {
        vm.startPrank(_for);
        TestVault vault = new TestVault();
        vm.stopPrank();

        return vault;
    }

    function _setUpVaultAndHooks(
        bytes32 _streamHash,
        address _for,
        IPayStreams.HookConfig memory _hookConfig
    )
        internal
        returns (TestVault)
    {
        vm.startPrank(_for);
        TestVault vault = new TestVault();
        stream.setVault(_streamHash, address(vault));
        stream.setHookConfig(_streamHash, _hookConfig);
        vm.stopPrank();

        return vault;
    }

    function _setFee(uint16 _newFee) internal {
        vm.startPrank(deployer);
        stream.setFeeInBasisPoints(_newFee);
        vm.stopPrank();
    }

    function _setGasLimitForHooks(uint256 _newGasLimit) internal {
        vm.startPrank(deployer);
        stream.setGasLimitForHooks(_newGasLimit);
        vm.stopPrank();
    }

    function _mintAndApprove(uint256 _amount) internal {
        token.mint(streamer, _amount);

        vm.startPrank(streamer);
        token.approve(address(stream), _amount);
        vm.stopPrank();
    }

    function _warpBy(uint256 _duration) internal {
        vm.warp(block.timestamp + _duration);
    }
}
