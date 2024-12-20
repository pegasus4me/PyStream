# IPayStreams
[Git Source](https://github.com/mgnfy-view/pystreams-monorepo/blob/c2bc4b1569db02cc5d60e647d96e72dffac4c56e/src/interfaces/IPayStreams.sol)


## Functions
### setFeeInBasisPoints


```solidity
function setFeeInBasisPoints(uint16 _feeInBasisPoints) external;
```

### setGasLimitForHooks


```solidity
function setGasLimitForHooks(uint256 _gasLimitForHooks) external;
```

### collectFees


```solidity
function collectFees(address _token, uint256 _amount, address _to) external;
```

### setStream


```solidity
function setStream(
    StreamData calldata _streamData,
    HookConfig calldata _streamerHookConfig,
    string calldata _tag
)
    external
    returns (bytes32);
```

### collectFundsFromStream


```solidity
function collectFundsFromStream(bytes32 _streamHash) external;
```

### updateStream


```solidity
function updateStream(
    bytes32 _streamHash,
    uint256 _amount,
    uint256 _startingTimestamp,
    uint256 _duration,
    bool _recurring,
    UpdateConfig calldata _updateConfig
)
    external;
```

### pauseStream


```solidity
function pauseStream(bytes32 _streamHash) external;
```

### unPauseStream


```solidity
function unPauseStream(bytes32 _streamHash) external;
```

### cancelStream


```solidity
function cancelStream(bytes32 _streamHash) external;
```

### setVaultAndHookConfig


```solidity
function setVaultAndHookConfig(bytes32 _streamHash, address _vault, HookConfig calldata _hookConfig) external;
```

### setVault


```solidity
function setVault(bytes32 _streamHash, address _vault) external;
```

### setHookConfig


```solidity
function setHookConfig(bytes32 _streamHash, HookConfig calldata _hookConfig) external;
```

### getFeeInBasisPoints


```solidity
function getFeeInBasisPoints() external view returns (uint16);
```

### getCollectedFees


```solidity
function getCollectedFees(address _token) external view returns (uint256);
```

### getStreamData


```solidity
function getStreamData(bytes32 _streamHash) external view returns (StreamData memory);
```

### getHookConfig


```solidity
function getHookConfig(address _user, bytes32 _streamHash) external view returns (HookConfig memory);
```

### getStreamerStreamHashes


```solidity
function getStreamerStreamHashes(address _streamer) external view returns (bytes32[] memory);
```

### getRecipientStreamHashes


```solidity
function getRecipientStreamHashes(address _recipient) external view returns (bytes32[] memory);
```

### getStreamHash


```solidity
function getStreamHash(
    address _streamer,
    address _recipient,
    address _token,
    string calldata _tag
)
    external
    pure
    returns (bytes32);
```

### getAmountToCollectFromStreamAndFeeToPay


```solidity
function getAmountToCollectFromStreamAndFeeToPay(bytes32 _streamHash) external view returns (uint256, uint256);
```

## Events
### FeeInBasisPointsSet

```solidity
event FeeInBasisPointsSet(address indexed by, uint16 indexed _feeInBasisPoints);
```

### GasLimitForHooksSet

```solidity
event GasLimitForHooksSet(address indexed by, uint256 indexed gasLimitForHooks);
```

### FeesCollected

```solidity
event FeesCollected(address indexed token, uint256 indexed amount, address indexed to);
```

### StreamCreated

```solidity
event StreamCreated(bytes32 indexed streamHash);
```

### FundsCollectedFromStream

```solidity
event FundsCollectedFromStream(bytes32 indexed streamHash, uint256 indexed amountToCollect, uint256 indexed feeAmount);
```

### StreamUpdated

```solidity
event StreamUpdated(
    bytes32 indexed streamHash,
    uint256 amount,
    uint256 startingTimestamp,
    uint256 duration,
    bool recurring,
    UpdateConfig updateConfig
);
```

### StreamPaused

```solidity
event StreamPaused(bytes32 indexed streamHash);
```

### StreamUnPaused

```solidity
event StreamUnPaused(bytes32 indexed streamHash);
```

### StreamCancelled

```solidity
event StreamCancelled(bytes32 indexed streamHash);
```

### VaultSet

```solidity
event VaultSet(address indexed by, bytes32 indexed streamHash, address indexed vault);
```

### HookConfigSet

```solidity
event HookConfigSet(address indexed by, bytes32 indexed streamHash);
```

## Errors
### PayStreams__InvalidFeeInBasisPoints

```solidity
error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
```

### PayStreams__GasLimitZero

```solidity
error PayStreams__GasLimitZero();
```

### PayStreams__InsufficientCollectedFees

```solidity
error PayStreams__InsufficientCollectedFees();
```

### PayStreams__InvalidStreamConfig

```solidity
error PayStreams__InvalidStreamConfig();
```

### PayStreams__StreamAlreadyExists

```solidity
error PayStreams__StreamAlreadyExists(bytes32 streamHash);
```

### PayStreams__StreamHasNotStartedYet

```solidity
error PayStreams__StreamHasNotStartedYet(bytes32 streamHash, uint256 startingTimestamp);
```

### PayStreams__InvalidUpdateParams

```solidity
error PayStreams__InvalidUpdateParams();
```

### PayStreams__CannotUpdateWhenStreamPaused

```solidity
error PayStreams__CannotUpdateWhenStreamPaused();
```

### PayStreams__CannotPauseStream

```solidity
error PayStreams__CannotPauseStream();
```

### PayStreams__NotPaused

```solidity
error PayStreams__NotPaused();
```

### PayStreams__ZeroAmountToCollect

```solidity
error PayStreams__ZeroAmountToCollect();
```

### PayStreams__Unauthorized

```solidity
error PayStreams__Unauthorized();
```

## Structs
### StreamData
The stream details struct.


```solidity
struct StreamData {
    address streamer;
    address streamerVault;
    address recipient;
    address recipientVault;
    address token;
    uint256 amount;
    uint256 startingTimestamp;
    uint256 duration;
    uint256 totalStreamed;
    bool recurring;
    uint256 lastPausedAt;
}
```

### HookConfig
The hook configuration details struct for both streamer and recipient.


```solidity
struct HookConfig {
    bool callAfterStreamCreated;
    bool callBeforeFundsCollected;
    bool callAfterFundsCollected;
    bool callBeforeStreamUpdated;
    bool callBeforeStreamPaused;
    bool callAfterStreamPaused;
    bool callBeforeStreamUnPaused;
    bool callAfterStreamUnPaused;
    bool callAfterStreamUpdated;
    bool callBeforeStreamClosed;
    bool callAfterStreamClosed;
}
```

### UpdateConfig
The update function can update all the 4 params - amount, starting timestamp,
duration, and the recurring variable. Flags must be passed to indicate which values
to update and which to ignore.


```solidity
struct UpdateConfig {
    bool updateAmount;
    bool updateStartingTimestamp;
    bool updateDuration;
    bool updateRecurring;
}
```

