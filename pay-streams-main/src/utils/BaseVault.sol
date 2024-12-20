// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IHooks } from "../interfaces/IHooks.sol";

/// @title BaseVault.
/// @author mgnfy-view.
/// @notice This base vault implementation can be extended by developers to build various
/// plugins on top of the payStreams protocol using hooks.
abstract contract BaseVault is Ownable, IHooks {
    using SafeERC20 for IERC20;

    event FundsCollected(address indexed token, uint256 indexed amount, address indexed to);

    error BaseVault__InsufficientFunds();

    constructor() Ownable(msg.sender) { }

    function afterStreamCreated(bytes32 _streamHash) external virtual { }

    function beforeFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external virtual { }

    function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external virtual { }

    function beforeStreamUpdated(bytes32 _streamHash) external virtual { }

    function afterStreamUpdated(bytes32 _streamHash) external virtual { }

    function beforeStreamPaused(bytes32 _streamHash) external virtual { }

    function afterStreamPaused(bytes32 _streamHash) external virtual { }

    function beforeStreamUnPaused(bytes32 _streamHash) external virtual { }

    function afterStreamUnPaused(bytes32 _streamHash) external virtual { }

    function beforeStreamClosed(bytes32 _streamHash) external virtual { }

    function afterStreamClosed(bytes32 _streamHash) external virtual { }

    /// @notice Allows the owner to collect funds from the vault.
    /// @param _token The token to be collected.
    /// @param _amount The amount of token to be collected.
    /// @param _to The recipient of the funds.
    function collectFunds(address _token, uint256 _amount, address _to) external virtual onlyOwner {
        if (IERC20(_token).balanceOf(address(this)) < _amount) revert BaseVault__InsufficientFunds();

        IERC20(_token).safeTransfer(_to, _amount);

        emit FundsCollected(_token, _amount, _to);
    }
}
