// Layout:
//     - pragma
//     - imports
//     - interfaces, libraries, contracts
//     - type declarations
//     - state variables
//     - events
//     - errors
//     - modifiers
//     - functions
//         - constructor
//         - receive function (if exists)
//         - fallback function (if exists)
//         - external
//         - public
//         - internal
//         - private
//         - view and pure functions

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IHooks } from "./interfaces/IHooks.sol";
import { IPayStreams } from "./interfaces/IPayStreams.sol";

/// @title PayStreams.
/// @author mgnfy-view.
/// @notice PayStreams is a payment streamming service supercharged with hooks.
contract PayStreams is Ownable, IPayStreams {
    using SafeERC20 for IERC20;

    uint16 private constant BASIS_POINTS = 10_000;

    /// @dev The fee applied on streams in basis points.
    uint16 private s_feeInBasisPoints;
    /// @dev Any fees collected from streams is stored in the contract and tracked by this mapping.
    mapping(address token => uint256 collectedFees) private s_collectedFees;
    /// @dev Stores stream details.
    mapping(bytes32 streamHash => StreamData streamData) private s_streamData;
    /// @dev Stores the hook configuration for the streamer and the recipient.
    mapping(address user => mapping(bytes32 streamHash => HookConfig hookConfig)) private s_hookConfig;
    /// @dev Utility storage for the streamer's stream hashes.
    mapping(address streamer => bytes32[] streamHashes) private s_streamerToStreamHashes;
    /// @dev Utility storage for the recipient's stream hashes.
    mapping(address recipient => bytes32[] streamHashes) private s_recipientToStreamHashes;
    /// @dev The maximum gas that a hook can use. This prevents gas griefing attacks.
    uint256 private s_gasLimitForHooks;

    /// @notice Initializes the owner and the fee value in basis points.
    /// @param _feeInBasisPoints The fee value in basis points.
    constructor(uint16 _feeInBasisPoints, uint256 _gasLimitForHooks) Ownable(msg.sender) {
        if (_feeInBasisPoints > BASIS_POINTS) revert PayStreams__InvalidFeeInBasisPoints(_feeInBasisPoints);
        s_feeInBasisPoints = _feeInBasisPoints;
        s_gasLimitForHooks = _gasLimitForHooks;
    }

    /// @notice Allows the owner to set the fee for streaming in basis points.
    /// @param _feeInBasisPoints The fee value in basis points.
    function setFeeInBasisPoints(uint16 _feeInBasisPoints) external onlyOwner {
        if (_feeInBasisPoints > BASIS_POINTS) revert PayStreams__InvalidFeeInBasisPoints(_feeInBasisPoints);
        s_feeInBasisPoints = _feeInBasisPoints;

        emit FeeInBasisPointsSet(msg.sender, _feeInBasisPoints);
    }

    /// @notice Allows the owner to set the gas limit for hooks.
    /// @param _gasLimitForHooks The gas limit for hooks.
    function setGasLimitForHooks(uint256 _gasLimitForHooks) external onlyOwner {
        if (_gasLimitForHooks == 0) revert PayStreams__GasLimitZero();
        s_gasLimitForHooks = _gasLimitForHooks;

        emit GasLimitForHooksSet(msg.sender, _gasLimitForHooks);
    }

    /// @notice Allows the owner to withdraw fees collected from streams.
    /// @param _token The address of the token.
    /// @param _amount The amount of collected fees to withdraw.
    /// @param _to The recipient of the funds.
    function collectFees(address _token, uint256 _amount, address _to) external onlyOwner {
        if (s_collectedFees[_token] < _amount) revert PayStreams__InsufficientCollectedFees();

        s_collectedFees[_token] -= _amount;
        IERC20(_token).safeTransfer(_to, _amount);

        emit FeesCollected(_token, _amount, _to);
    }

    /// @notice Allows anyone to create a stream with custom parameters and hook configuration.
    /// @param _streamData The stream details.
    /// @param _streamerHookConfig The streamer's hook configuration.
    /// @param _tag Salt for stream creation. This allows a streamer to create multiple streams for different
    /// purposes targeted towards the same recipient and using the same token.
    /// @return The hash of the newly created stream.
    function setStream(
        StreamData calldata _streamData,
        HookConfig calldata _streamerHookConfig,
        string calldata _tag
    )
        external
        returns (bytes32)
    {
        if (
            _streamData.streamer != msg.sender || _streamData.recipient == address(0)
                || _streamData.recipientVault != address(0) || _streamData.amount == 0
                || _streamData.startingTimestamp < block.timestamp || _streamData.duration == 0
                || _streamData.totalStreamed != 0 || _streamData.lastPausedAt != 0
        ) revert PayStreams__InvalidStreamConfig();

        bytes32 streamHash = getStreamHash(msg.sender, _streamData.recipient, _streamData.token, _tag);
        if (s_streamData[streamHash].streamer != address(0)) revert PayStreams__StreamAlreadyExists(streamHash);
        s_streamData[streamHash] = _streamData;
        s_streamerToStreamHashes[msg.sender].push(streamHash);
        s_recipientToStreamHashes[_streamData.recipient].push(streamHash);
        s_hookConfig[msg.sender][streamHash] = _streamerHookConfig;

        if (_streamData.streamerVault != address(0) && _streamerHookConfig.callAfterStreamCreated) {
            IHooks(_streamData.streamerVault).afterStreamCreated{ gas: s_gasLimitForHooks }(streamHash);
        }

        emit StreamCreated(streamHash);

        return streamHash;
    }

    /// @notice Allows the recipient to collect funds from a stream. Can be called by anyone.
    /// @param _streamHash The hash of the stream.
    function collectFundsFromStream(bytes32 _streamHash) external {
        StreamData memory streamData = s_streamData[_streamHash];
        uint256 gasLimitForHooks = s_gasLimitForHooks;

        if (streamData.startingTimestamp > block.timestamp) {
            revert PayStreams__StreamHasNotStartedYet(_streamHash, streamData.startingTimestamp);
        }
        (uint256 amountToCollect, uint256 feeAmount) = getAmountToCollectFromStreamAndFeeToPay(_streamHash);
        if (amountToCollect == 0) revert PayStreams__ZeroAmountToCollect();

        s_streamData[_streamHash].totalStreamed += amountToCollect + feeAmount;

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.recipient][_streamHash];

        if (streamData.streamerVault != address(0) && streamerHookConfig.callBeforeFundsCollected) {
            IHooks(streamData.streamerVault).beforeFundsCollected{ gas: gasLimitForHooks }(
                _streamHash, amountToCollect, feeAmount
            );
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callBeforeFundsCollected) {
            IHooks(streamData.recipientVault).beforeFundsCollected{ gas: gasLimitForHooks }(
                _streamHash, amountToCollect, feeAmount
            );
        }

        s_collectedFees[streamData.token] += feeAmount;
        if (streamData.streamerVault != address(0)) {
            streamData.recipientVault != address(0)
                ? IERC20(streamData.token).safeTransferFrom(
                    streamData.streamerVault, streamData.recipientVault, amountToCollect
                )
                : IERC20(streamData.token).safeTransferFrom(streamData.streamerVault, streamData.recipient, amountToCollect);

            IERC20(streamData.token).safeTransferFrom(streamData.streamerVault, address(this), feeAmount);
        } else {
            streamData.recipientVault != address(0)
                ? IERC20(streamData.token).safeTransferFrom(streamData.streamer, streamData.recipientVault, amountToCollect)
                : IERC20(streamData.token).safeTransferFrom(streamData.streamer, streamData.recipient, amountToCollect);

            IERC20(streamData.token).safeTransferFrom(streamData.streamer, address(this), feeAmount);
        }

        if (streamData.streamerVault != address(0) && streamerHookConfig.callAfterFundsCollected) {
            IHooks(streamData.streamerVault).afterFundsCollected{ gas: gasLimitForHooks }(
                _streamHash, amountToCollect, feeAmount
            );
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callAfterFundsCollected) {
            IHooks(streamData.recipientVault).afterFundsCollected{ gas: gasLimitForHooks }(
                _streamHash, amountToCollect, feeAmount
            );
        }

        emit FundsCollectedFromStream(_streamHash, amountToCollect, feeAmount);
    }

    /// @notice Allows the creator of a stream to update the stream parameters.
    /// @param _streamHash The hash of the stream.
    /// @param _amount The new amount to stream.
    /// @param _startingTimestamp The new starting timestamp.
    /// @param _duration The new stream duration.
    /// @param _recurring Update stream to be recurring or not.
    function updateStream(
        bytes32 _streamHash,
        uint256 _amount,
        uint256 _startingTimestamp,
        uint256 _duration,
        bool _recurring,
        UpdateConfig calldata _updateConfig
    )
        external
    {
        StreamData memory streamData = s_streamData[_streamHash];
        uint256 gasLimitForHooks = s_gasLimitForHooks;
        _checkIfStreamCreator(streamData);

        if (
            (_updateConfig.updateAmount && _amount < streamData.totalStreamed)
                || (_updateConfig.updateStartingTimestamp && _startingTimestamp < block.timestamp)
                || (_updateConfig.updateDuration && _duration == 0)
        ) {
            revert PayStreams__InvalidUpdateParams();
        }
        if (streamData.lastPausedAt != 0) revert PayStreams__CannotUpdateWhenStreamPaused();

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.recipient][_streamHash];

        if (streamData.streamerVault != address(0) && streamerHookConfig.callBeforeStreamUpdated) {
            IHooks(streamData.streamerVault).beforeStreamUpdated{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callBeforeStreamUpdated) {
            IHooks(streamData.recipientVault).beforeStreamUpdated{ gas: gasLimitForHooks }(_streamHash);
        }

        if (_updateConfig.updateAmount) s_streamData[_streamHash].amount = _amount;
        if (_updateConfig.updateStartingTimestamp) s_streamData[_streamHash].startingTimestamp = _startingTimestamp;
        if (_updateConfig.updateDuration) s_streamData[_streamHash].duration = _duration;
        if (_updateConfig.updateRecurring) s_streamData[_streamHash].recurring = _recurring;

        if (streamData.streamerVault != address(0) && streamerHookConfig.callAfterStreamUpdated) {
            IHooks(streamData.streamerVault).afterStreamUpdated{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callAfterStreamUpdated) {
            IHooks(streamData.recipientVault).afterStreamUpdated{ gas: gasLimitForHooks }(_streamHash);
        }

        emit StreamUpdated(_streamHash, _amount, _startingTimestamp, _duration, _recurring, _updateConfig);
    }

    /// @notice Allows a streamer to pause an ongoing stream.
    /// @param _streamHash The hash of the stream.
    function pauseStream(bytes32 _streamHash) external {
        StreamData memory streamData = s_streamData[_streamHash];
        uint256 gasLimitForHooks = s_gasLimitForHooks;
        _checkIfStreamCreator(streamData);

        if (
            block.timestamp < streamData.startingTimestamp
                || (block.timestamp > streamData.startingTimestamp + streamData.duration && !streamData.recurring)
                || streamData.lastPausedAt != 0
        ) revert PayStreams__CannotPauseStream();

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.recipient][_streamHash];

        if (streamData.streamerVault != address(0) && streamerHookConfig.callBeforeStreamPaused) {
            IHooks(streamData.streamerVault).beforeStreamPaused{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callBeforeStreamPaused) {
            IHooks(streamData.recipientVault).beforeStreamPaused{ gas: gasLimitForHooks }(_streamHash);
        }

        s_streamData[_streamHash].lastPausedAt = block.timestamp;

        if (streamData.streamerVault != address(0) && streamerHookConfig.callAfterStreamPaused) {
            IHooks(streamData.streamerVault).afterStreamPaused{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callAfterStreamPaused) {
            IHooks(streamData.recipientVault).afterStreamPaused{ gas: gasLimitForHooks }(_streamHash);
        }

        emit StreamPaused(_streamHash);
    }

    /// @notice Allows a streamer to unpause a paused stream.
    /// @param _streamHash The hash of the stream.
    function unPauseStream(bytes32 _streamHash) external {
        StreamData memory streamData = s_streamData[_streamHash];
        uint256 gasLimitForHooks = s_gasLimitForHooks;
        _checkIfStreamCreator(streamData);

        if (streamData.lastPausedAt == 0) revert PayStreams__NotPaused();

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.recipient][_streamHash];

        if (streamData.streamerVault != address(0) && streamerHookConfig.callBeforeStreamUnPaused) {
            IHooks(streamData.streamerVault).beforeStreamUnPaused{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callBeforeStreamUnPaused) {
            IHooks(streamData.recipientVault).beforeStreamUnPaused{ gas: gasLimitForHooks }(_streamHash);
        }

        s_streamData[_streamHash].startingTimestamp =
            block.timestamp - (streamData.lastPausedAt - streamData.startingTimestamp);
        s_streamData[_streamHash].lastPausedAt = 0;

        if (streamData.streamerVault != address(0) && streamerHookConfig.callAfterStreamUnPaused) {
            IHooks(streamData.streamerVault).afterStreamUnPaused{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callAfterStreamUnPaused) {
            IHooks(streamData.recipientVault).afterStreamUnPaused{ gas: gasLimitForHooks }(_streamHash);
        }

        emit StreamUnPaused(_streamHash);
    }

    /// @notice Allows the creator of a stream to cancel the stream.
    /// @param _streamHash The hash of the stream.
    function cancelStream(bytes32 _streamHash) external {
        StreamData memory streamData = s_streamData[_streamHash];
        uint256 gasLimitForHooks = s_gasLimitForHooks;
        _checkIfStreamCreator(streamData);

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.recipient][_streamHash];

        if (streamData.streamerVault != address(0) && streamerHookConfig.callBeforeStreamClosed) {
            IHooks(streamData.streamerVault).beforeStreamClosed{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callBeforeStreamClosed) {
            IHooks(streamData.recipientVault).beforeStreamClosed{ gas: gasLimitForHooks }(_streamHash);
        }

        s_streamData[_streamHash].amount = 0;

        if (streamData.streamerVault != address(0) && streamerHookConfig.callAfterStreamClosed) {
            IHooks(streamData.streamerVault).afterStreamClosed{ gas: gasLimitForHooks }(_streamHash);
        }
        if (streamData.recipientVault != address(0) && recipientHookConfig.callAfterStreamClosed) {
            IHooks(streamData.recipientVault).afterStreamClosed{ gas: gasLimitForHooks }(_streamHash);
        }

        emit StreamCancelled(_streamHash);
    }

    /// @notice Sets the vault and hook config for streamer/recipient.
    /// @param _streamHash The hash of the stream.
    /// @param _vault The streamer's or recipient's vault address.
    /// @param _hookConfig The streamer's or recipient's hook configuration.
    function setVaultAndHookConfig(bytes32 _streamHash, address _vault, HookConfig calldata _hookConfig) external {
        setVault(_streamHash, _vault);
        setHookConfig(_streamHash, _hookConfig);
    }

    /// @notice Allows the streamer or recipient of a stream to set their respective vaults.
    /// @dev Hooks can only be called on correctly configured and set vaults (both on streamer's
    /// and recipient's end).
    /// @param _streamHash The hash of the stream.
    /// @param _vault The streamer's or recipient's vault address.
    function setVault(bytes32 _streamHash, address _vault) public {
        StreamData memory streamData = s_streamData[_streamHash];
        _checkIfCreatorOrStreamer(streamData);

        msg.sender == streamData.streamer
            ? s_streamData[_streamHash].streamerVault = _vault
            : s_streamData[_streamHash].recipientVault = _vault;

        emit VaultSet(msg.sender, _streamHash, _vault);
    }

    /// @notice Allows streamers and recipients to set their hook configuration.
    /// @param _streamHash The hash of the stream.
    /// @param _hookConfig The streamer's or recipient's hook configuration.
    function setHookConfig(bytes32 _streamHash, HookConfig calldata _hookConfig) public {
        StreamData memory streamData = s_streamData[_streamHash];
        if (msg.sender != streamData.streamer && msg.sender != streamData.recipient) revert PayStreams__Unauthorized();

        s_hookConfig[msg.sender][_streamHash] = _hookConfig;

        emit HookConfigSet(msg.sender, _streamHash);
    }

    /// @notice Checks if the caller is the creator of the stream.
    /// @param _streamData The stream details.
    function _checkIfStreamCreator(StreamData memory _streamData) internal view {
        if (msg.sender != _streamData.streamer) revert PayStreams__Unauthorized();
    }

    /// @notice Checks if the caller is the creator or recipient of the stream.
    /// @param _streamData The stream details.
    function _checkIfCreatorOrStreamer(StreamData memory _streamData) internal view {
        if (msg.sender != _streamData.streamer && msg.sender != _streamData.recipient) {
            revert PayStreams__Unauthorized();
        }
    }

    /// @notice Gets the fee value for streaming in basis points.
    /// @return The fee value for streaming in basis points.
    function getFeeInBasisPoints() external view returns (uint16) {
        return s_feeInBasisPoints;
    }

    /// @notice Gets the total amount collected in fees for a given token.
    /// @param _token The address of the token.
    /// @return The amount of token collected in fees.
    function getCollectedFees(address _token) external view returns (uint256) {
        return s_collectedFees[_token];
    }

    /// @notice Gets the details for a given stream.
    /// @param _streamHash The hash of the stream.
    /// @return The stream details.
    function getStreamData(bytes32 _streamHash) external view returns (StreamData memory) {
        return s_streamData[_streamHash];
    }

    /// @notice Gets the hook configuration for a given user and a given stream hash.
    /// @param _user The user's address.
    /// @param _streamHash The hash of the stream.
    /// @return The hook configuration details.
    function getHookConfig(address _user, bytes32 _streamHash) external view returns (HookConfig memory) {
        return s_hookConfig[_user][_streamHash];
    }

    /// @notice Gets the hashes of the streams created by a user.
    /// @param _streamer The stream creator's address.
    /// @return An array of stream hashes.
    function getStreamerStreamHashes(address _streamer) external view returns (bytes32[] memory) {
        return s_streamerToStreamHashes[_streamer];
    }

    /// @notice Gets the hashes of the streams the user is a recipient of.
    /// @param _recipient The stream recipient's address.
    /// @return An array of stream hashes.
    function getRecipientStreamHashes(address _recipient) external view returns (bytes32[] memory) {
        return s_recipientToStreamHashes[_recipient];
    }

    /// @notice Gets the gas limit for hooks.
    /// @return The gas limit for hooks.
    function getGasLimitForHooks() external view returns (uint256) {
        return s_gasLimitForHooks;
    }

    /// @notice Computes the hash of a stream from the streamer, recipient, token addresses and a string tag.
    /// @param _streamer The address of the stream creator.
    /// @param _recipient The address of the stream recipient.
    /// @param _token The address of the token.
    /// @param _tag Salt for stream creation.
    /// @return The hash of the stream.
    function getStreamHash(
        address _streamer,
        address _recipient,
        address _token,
        string calldata _tag
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_streamer, _recipient, _token, _tag));
    }

    /// @notice Gets the amount withdrawable from the stream as well as the fee amount.
    /// @param _streamHash The hash of the stream.
    /// @return The amount of funds withdrawable from the stream.
    /// @return The fee amount applied to the withdrawable funds.
    function getAmountToCollectFromStreamAndFeeToPay(bytes32 _streamHash) public view returns (uint256, uint256) {
        StreamData memory streamData = s_streamData[_streamHash];
        if (block.timestamp < streamData.startingTimestamp) return (0, 0);

        uint256 amountToCollect;
        if (streamData.lastPausedAt != 0) {
            amountToCollect =
                (streamData.amount * (streamData.lastPausedAt - streamData.startingTimestamp) / streamData.duration);
        } else {
            amountToCollect =
                (streamData.amount * (block.timestamp - streamData.startingTimestamp) / streamData.duration);
        }
        if (amountToCollect > streamData.amount && !streamData.recurring) {
            amountToCollect = streamData.amount;
        }
        amountToCollect -= streamData.totalStreamed;
        uint256 feeAmount = (amountToCollect * s_feeInBasisPoints) / BASIS_POINTS;

        return (amountToCollect - feeAmount, feeAmount);
    }
}
