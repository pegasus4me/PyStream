// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { BaseVault } from "../../src/utils/BaseVault.sol";

contract TestVault is BaseVault {
    event CalledAfterStreamCreated(bytes32 indexed streamHash);
    event CalledBeforeFundsCollected(bytes32 indexed streamHash, uint256 indexed amount, uint256 indexed feeAmount);
    event CalledAfterFundsCollected(bytes32 indexed streamHash, uint256 indexed amount, uint256 indexed feeAmount);
    event CalledBeforeStreamUpdated(bytes32 indexed streamHash);
    event CalledAfterStreamUpdated(bytes32 indexed streamHash);
    event CalledBeforeStreamPaused(bytes32 indexed streamHash);
    event CalledAfterStreamPaused(bytes32 indexed streamHash);
    event CalledBeforeStreamUnPaused(bytes32 indexed streamHash);
    event CalledAfterStreamUnPaused(bytes32 indexed streamHash);
    event CalledBeforeStreamClosed(bytes32 indexed streamHash);
    event CalledAfterStreamClosed(bytes32 indexed streamHash);

    function approve(address _token, address _spender, uint256 _amount) external onlyOwner {
        IERC20(_token).approve(_spender, _amount);
    }

    function afterStreamCreated(bytes32 _streamHash) external override {
        emit CalledAfterStreamCreated(_streamHash);
    }

    function beforeFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external override {
        emit CalledBeforeFundsCollected(_streamHash, _amount, _feeAmount);
    }

    function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external override {
        emit CalledAfterFundsCollected(_streamHash, _amount, _feeAmount);
    }

    function beforeStreamUpdated(bytes32 _streamHash) external override {
        emit CalledBeforeStreamUpdated(_streamHash);
    }

    function afterStreamUpdated(bytes32 _streamHash) external override {
        emit CalledAfterStreamUpdated(_streamHash);
    }

    function beforeStreamPaused(bytes32 _streamHash) external override {
        emit CalledBeforeStreamPaused(_streamHash);
    }

    function afterStreamPaused(bytes32 _streamHash) external override {
        emit CalledAfterStreamPaused(_streamHash);
    }

    function beforeStreamUnPaused(bytes32 _streamHash) external override {
        emit CalledBeforeStreamUnPaused(_streamHash);
    }

    function afterStreamUnPaused(bytes32 _streamHash) external override {
        emit CalledAfterStreamUnPaused(_streamHash);
    }

    function beforeStreamClosed(bytes32 _streamHash) external override {
        emit CalledBeforeStreamClosed(_streamHash);
    }

    function afterStreamClosed(bytes32 _streamHash) external override {
        emit CalledAfterStreamClosed(_streamHash);
    }
}
