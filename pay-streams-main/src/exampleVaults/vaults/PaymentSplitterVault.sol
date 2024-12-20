// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IPayStreams } from "../../interfaces/IPayStreams.sol";

import { BaseVault } from "../../utils/BaseVault.sol";

/// @title PaymentSplitterVault.
/// @author mgnfy-view.
/// @notice A payment splitter vault that splits any streamed payment among a
/// list of recipients based on their assigned weights.
contract PaymentSplitterVault is BaseVault {
    using SafeERC20 for IERC20;

    address private s_payStreams;
    address[] private s_recipients;
    uint256[] private s_weights;
    uint256 private s_totalWeight;

    event PaymentSplit(address[] indexed recipients, uint256[] indexed amounts);
    event RecipientAndWeightsListUpdated(address[] indexed recipients, uint256[] indexed weights);

    error PaymentSplitterVault__ArrayLengthMismatch();
    error PaymentSplitterVault__NotPayStream();

    modifier onlyPayStreams() {
        if (msg.sender != address(s_payStreams)) revert PaymentSplitterVault__NotPayStream();
        _;
    }

    /// @notice Initializes the vault.
    /// @param _payStreams The address of the payStreams contract.
    /// @param _recipients A list of recipients of the streamed amount.
    /// @param _weights Assigned weight to each recipient in the list.
    constructor(address _payStreams, address[] memory _recipients, uint256[] memory _weights) {
        if (_recipients.length != _weights.length) revert PaymentSplitterVault__ArrayLengthMismatch();

        s_payStreams = _payStreams;
        s_recipients = _recipients;
        s_weights = _weights;

        uint256 totalWeight;
        for (uint256 i; i < _weights.length; ++i) {
            totalWeight += _weights[i];
        }
        s_totalWeight = totalWeight;
    }

    /// @notice Once funds have been received by this vault, this function is invoked by the
    /// payStreams contract to split the streamed funds among multiple recipients based on their weight.
    /// @param _streamHash The hash of the stream.
    /// @param _amount The amount to received from stream.
    function afterFundsCollected(
        bytes32 _streamHash,
        uint256 _amount,
        uint256 /* _feeAmount */
    )
        external
        override
        onlyPayStreams
    {
        address token = IPayStreams(s_payStreams).getStreamData(_streamHash).token;
        address[] memory recipients = s_recipients;
        uint256[] memory weights = s_weights;
        uint256 numberOfRecipients = recipients.length;
        uint256 totalWeight = s_totalWeight;
        uint256[] memory amounts = new uint256[](numberOfRecipients);

        for (uint256 i; i < numberOfRecipients; ++i) {
            uint256 amount = (_amount * weights[i]) / totalWeight;
            amounts[i] = amount;
            IERC20(token).safeTransfer(recipients[i], amount);
        }

        emit PaymentSplit(recipients, amounts);
    }

    /// @notice Allows the owner to update the recipient and the weights list.
    /// @param _recipients The new list of recipients.
    /// @param _weights The weights assigned to each recipient.
    function updateRecipientAndWeightsList(
        address[] memory _recipients,
        uint256[] memory _weights
    )
        external
        onlyOwner
    {
        if (_recipients.length != _weights.length) revert PaymentSplitterVault__ArrayLengthMismatch();
        s_recipients = _recipients;
        s_weights = _weights;

        uint256 totalWeight;
        for (uint256 i; i < _weights.length; ++i) {
            totalWeight += _weights[i];
        }
        s_totalWeight = totalWeight;

        emit RecipientAndWeightsListUpdated(_recipients, _weights);
    }

    /// @notice Gets the payStreams contract address.
    /// @return The payStreams contract address.
    function getPayStreams() external view returns (address) {
        return s_payStreams;
    }

    /// @notice Gets the recipients list.
    /// @return The recipients list.
    function getRecipients() external view returns (address[] memory) {
        return s_recipients;
    }

    /// @notice Gets the weights list.
    /// @return The weights list.
    function getWeights() external view returns (uint256[] memory) {
        return s_weights;
    }

    /// @notice Gets the total weight based on the weights list.
    /// @return The total weight.
    function getTotalWeight() external view returns (uint256) {
        return s_totalWeight;
    }
}
