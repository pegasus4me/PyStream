// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IPayStreams {
    /// @notice The stream details struct.
    struct StreamData {
        /// @dev The address of the streamer.
        address streamer;
        /// @dev The address of the streamer's vault.
        address streamerVault;
        /// @dev The address of the recipient.
        address recipient;
        /// @dev The address of the recipient's vault.
        address recipientVault;
        /// @dev The address of the token to stream.
        address token;
        /// @dev The amount of the token to stream.
        uint256 amount;
        /// @dev The timestamp when the stream begins.
        uint256 startingTimestamp;
        /// @dev The duration for which the stream lasts.
        uint256 duration;
        /// @dev The total amount collected by recipient from the stream.
        uint256 totalStreamed;
        /// @dev A bool indicating if the stream is recurring or one-time only.
        bool recurring;
        /// @dev The timestamp when the stream was paused. If not paused, it's set to 0
        uint256 lastPausedAt;
    }

    /// @notice The hook configuration details struct for both streamer and recipient.
    struct HookConfig {
        /// @dev If set, the afterStreamCreated() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterStreamCreated;
        /// @dev If set, the beforeFundsCollected() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callBeforeFundsCollected;
        /// @dev If set, the afterFundsCollected() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterFundsCollected;
        /// @dev If set, the beforeStreamUpdated() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callBeforeStreamUpdated;
        /// @dev If set, the beforeStreamPaused() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callBeforeStreamPaused;
        /// @dev If set, the afterStreamPaused() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterStreamPaused;
        /// @dev If set, the beforeStreamUnPaused() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callBeforeStreamUnPaused;
        /// @dev If set, the afterStreamUnPaused() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterStreamUnPaused;
        /// @dev If set, the afterStreamUpdated() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterStreamUpdated;
        /// @dev If set, the beforeStreamClosed() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callBeforeStreamClosed;
        /// @dev If set, the afterStreamClosed() function will be called on
        /// the user's vault (if it isn't address(0)).
        bool callAfterStreamClosed;
    }

    /// @notice The update function can update all the 4 params - amount, starting timestamp,
    /// duration, and the recurring variable. Flags must be passed to indicate which values
    /// to update and which to ignore.
    struct UpdateConfig {
        /// @dev A boolean indicating whether to update the amount or not.
        bool updateAmount;
        /// @dev A boolean indicating whether to update the starting timestamp or not.
        bool updateStartingTimestamp;
        /// @dev A boolean indicating whether to update the duration or not.
        bool updateDuration;
        /// @dev A boolean indicating whether to update the recurring variable or not.
        bool updateRecurring;
    }

    event FeeInBasisPointsSet(address indexed by, uint16 indexed _feeInBasisPoints);
    event GasLimitForHooksSet(address indexed by, uint256 indexed gasLimitForHooks);
    event FeesCollected(address indexed token, uint256 indexed amount, address indexed to);
    event StreamCreated(bytes32 indexed streamHash);
    event FundsCollectedFromStream(
        bytes32 indexed streamHash, uint256 indexed amountToCollect, uint256 indexed feeAmount
    );
    event StreamUpdated(
        bytes32 indexed streamHash,
        uint256 amount,
        uint256 startingTimestamp,
        uint256 duration,
        bool recurring,
        UpdateConfig updateConfig
    );
    event StreamPaused(bytes32 indexed streamHash);
    event StreamUnPaused(bytes32 indexed streamHash);
    event StreamCancelled(bytes32 indexed streamHash);
    event VaultSet(address indexed by, bytes32 indexed streamHash, address indexed vault);
    event HookConfigSet(address indexed by, bytes32 indexed streamHash);

    error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
    error PayStreams__GasLimitZero();
    error PayStreams__InsufficientCollectedFees();
    error PayStreams__InvalidStreamConfig();
    error PayStreams__StreamAlreadyExists(bytes32 streamHash);
    error PayStreams__StreamHasNotStartedYet(bytes32 streamHash, uint256 startingTimestamp);
    error PayStreams__InvalidUpdateParams();
    error PayStreams__CannotUpdateWhenStreamPaused();
    error PayStreams__CannotPauseStream();
    error PayStreams__NotPaused();
    error PayStreams__ZeroAmountToCollect();
    error PayStreams__Unauthorized();

    function setFeeInBasisPoints(uint16 _feeInBasisPoints) external;
    function setGasLimitForHooks(uint256 _gasLimitForHooks) external;
    function collectFees(address _token, uint256 _amount, address _to) external;
    function setStream(
        StreamData calldata _streamData,
        HookConfig calldata _streamerHookConfig,
        string calldata _tag
    )
        external
        returns (bytes32);
    function collectFundsFromStream(bytes32 _streamHash) external;
    function updateStream(
        bytes32 _streamHash,
        uint256 _amount,
        uint256 _startingTimestamp,
        uint256 _duration,
        bool _recurring,
        UpdateConfig calldata _updateConfig
    )
        external;
    function pauseStream(bytes32 _streamHash) external;
    function unPauseStream(bytes32 _streamHash) external;
    function cancelStream(bytes32 _streamHash) external;
    function setVaultAndHookConfig(bytes32 _streamHash, address _vault, HookConfig calldata _hookConfig) external;
    function setVault(bytes32 _streamHash, address _vault) external;
    function setHookConfig(bytes32 _streamHash, HookConfig calldata _hookConfig) external;
    function getFeeInBasisPoints() external view returns (uint16);
    function getCollectedFees(address _token) external view returns (uint256);
    function getStreamData(bytes32 _streamHash) external view returns (StreamData memory);
    function getHookConfig(address _user, bytes32 _streamHash) external view returns (HookConfig memory);
    function getStreamerStreamHashes(address _streamer) external view returns (bytes32[] memory);
    function getRecipientStreamHashes(address _recipient) external view returns (bytes32[] memory);
    function getStreamHash(
        address _streamer,
        address _recipient,
        address _token,
        string calldata _tag
    )
        external
        pure
        returns (bytes32);
    function getAmountToCollectFromStreamAndFeeToPay(bytes32 _streamHash) external view returns (uint256, uint256);
}
