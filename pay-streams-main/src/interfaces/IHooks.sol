// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IHooks {
    function afterStreamCreated(bytes32 _streamHash) external;

    function beforeFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external;

    function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external;

    function beforeStreamUpdated(bytes32 _streamHash) external;

    function afterStreamUpdated(bytes32 _streamHash) external;

    function beforeStreamPaused(bytes32 _streamHash) external;

    function afterStreamPaused(bytes32 _streamHash) external;

    function beforeStreamUnPaused(bytes32 _streamHash) external;

    function afterStreamUnPaused(bytes32 _streamHash) external;

    function beforeStreamClosed(bytes32 _streamHash) external;

    function afterStreamClosed(bytes32 _streamHash) external;
}
