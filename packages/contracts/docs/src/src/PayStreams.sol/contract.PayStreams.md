# PayStreams
[Git Source](https://github.com/mgnfy-view/pystreams-monorepo/blob/c2bc4b1569db02cc5d60e647d96e72dffac4c56e/src/PayStreams.sol)

**Inherits:**
Ownable, [IPayStreams](/src/interfaces/IPayStreams.sol/interface.IPayStreams.md)

**Author:**
mgnfy-view.

PayStreams is a payment streamming service supercharged with hooks.


## State Variables
### BASIS_POINTS

```solidity
uint16 private constant BASIS_POINTS = 10_000;
```


### s_feeInBasisPoints
*The fee applied on streams in basis points.*


```solidity
uint16 private s_feeInBasisPoints;
```


### s_collectedFees
*Any fees collected from streams is stored in the contract and tracked by this mapping.*


```solidity
mapping(address token => uint256 collectedFees) private s_collectedFees;
```


### s_streamData
*Stores stream details.*


```solidity
mapping(bytes32 streamHash => StreamData streamData) private s_streamData;
```


### s_hookConfig
*Stores the hook configuration for the streamer and the recipient.*


```solidity
mapping(address user => mapping(bytes32 streamHash => HookConfig hookConfig)) private s_hookConfig;
```


### s_streamerToStreamHashes
*Utility storage for the streamer's stream hashes.*


```solidity
mapping(address streamer => bytes32[] streamHashes) private s_streamerToStreamHashes;
```


### s_recipientToStreamHashes
*Utility storage for the recipient's stream hashes.*


```solidity
mapping(address recipient => bytes32[] streamHashes) private s_recipientToStreamHashes;
```


### s_gasLimitForHooks
*The maximum gas that a hook can use. This prevents gas griefing attacks.*


```solidity
uint256 private s_gasLimitForHooks;
```


## Functions
### constructor

Initializes the owner and the fee value in basis points.


```solidity
constructor(uint16 _feeInBasisPoints, uint256 _gasLimitForHooks) Ownable(msg.sender);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_feeInBasisPoints`|`uint16`|The fee value in basis points.|
|`_gasLimitForHooks`|`uint256`||


### setFeeInBasisPoints

Allows the owner to set the fee for streaming in basis points.


```solidity
function setFeeInBasisPoints(uint16 _feeInBasisPoints) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_feeInBasisPoints`|`uint16`|The fee value in basis points.|


### setGasLimitForHooks

Allows the owner to set the gas limit for hooks.


```solidity
function setGasLimitForHooks(uint256 _gasLimitForHooks) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_gasLimitForHooks`|`uint256`|The gas limit for hooks.|


### collectFees

Allows the owner to withdraw fees collected from streams.


```solidity
function collectFees(address _token, uint256 _amount, address _to) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|The address of the token.|
|`_amount`|`uint256`|The amount of collected fees to withdraw.|
|`_to`|`address`|The recipient of the funds.|


### setStream

Allows anyone to create a stream with custom parameters and hook configuration.


```solidity
function setStream(
    StreamData calldata _streamData,
    HookConfig calldata _streamerHookConfig,
    string calldata _tag
)
    external
    returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamData`|`StreamData`|The stream details.|
|`_streamerHookConfig`|`HookConfig`|The streamer's hook configuration.|
|`_tag`|`string`|Salt for stream creation. This allows a streamer to create multiple streams for different purposes targeted towards the same recipient and using the same token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The hash of the newly created stream.|


### collectFundsFromStream

Allows the recipient to collect funds from a stream. Can be called by anyone.


```solidity
function collectFundsFromStream(bytes32 _streamHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|


### updateStream

Allows the creator of a stream to update the stream parameters.


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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|
|`_amount`|`uint256`|The new amount to stream.|
|`_startingTimestamp`|`uint256`|The new starting timestamp.|
|`_duration`|`uint256`|The new stream duration.|
|`_recurring`|`bool`|Update stream to be recurring or not.|
|`_updateConfig`|`UpdateConfig`||


### pauseStream

Allows a streamer to pause an ongoing stream.


```solidity
function pauseStream(bytes32 _streamHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|


### unPauseStream

Allows a streamer to unpause a paused stream.


```solidity
function unPauseStream(bytes32 _streamHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|


### cancelStream

Allows the creator of a stream to cancel the stream.


```solidity
function cancelStream(bytes32 _streamHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|


### setVaultAndHookConfig

Sets the vault and hook config for streamer/recipient.


```solidity
function setVaultAndHookConfig(bytes32 _streamHash, address _vault, HookConfig calldata _hookConfig) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|
|`_vault`|`address`|The streamer's or recipient's vault address.|
|`_hookConfig`|`HookConfig`|The streamer's or recipient's hook configuration.|


### setVault

Allows the streamer or recipient of a stream to set their respective vaults.

*Hooks can only be called on correctly configured and set vaults (both on streamer's
and recipient's end).*


```solidity
function setVault(bytes32 _streamHash, address _vault) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|
|`_vault`|`address`|The streamer's or recipient's vault address.|


### setHookConfig

Allows streamers and recipients to set their hook configuration.


```solidity
function setHookConfig(bytes32 _streamHash, HookConfig calldata _hookConfig) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|
|`_hookConfig`|`HookConfig`|The streamer's or recipient's hook configuration.|


### _checkIfStreamCreator

Checks if the caller is the creator of the stream.


```solidity
function _checkIfStreamCreator(StreamData memory _streamData) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamData`|`StreamData`|The stream details.|


### _checkIfCreatorOrStreamer

Checks if the caller is the creator or recipient of the stream.


```solidity
function _checkIfCreatorOrStreamer(StreamData memory _streamData) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamData`|`StreamData`|The stream details.|


### getFeeInBasisPoints

Gets the fee value for streaming in basis points.


```solidity
function getFeeInBasisPoints() external view returns (uint16);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint16`|The fee value for streaming in basis points.|


### getCollectedFees

Gets the total amount collected in fees for a given token.


```solidity
function getCollectedFees(address _token) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|The address of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of token collected in fees.|


### getStreamData

Gets the details for a given stream.


```solidity
function getStreamData(bytes32 _streamHash) external view returns (StreamData memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StreamData`|The stream details.|


### getHookConfig

Gets the hook configuration for a given user and a given stream hash.


```solidity
function getHookConfig(address _user, bytes32 _streamHash) external view returns (HookConfig memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The user's address.|
|`_streamHash`|`bytes32`|The hash of the stream.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`HookConfig`|The hook configuration details.|


### getStreamerStreamHashes

Gets the hashes of the streams created by a user.


```solidity
function getStreamerStreamHashes(address _streamer) external view returns (bytes32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamer`|`address`|The stream creator's address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32[]`|An array of stream hashes.|


### getRecipientStreamHashes

Gets the hashes of the streams the user is a recipient of.


```solidity
function getRecipientStreamHashes(address _recipient) external view returns (bytes32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The stream recipient's address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32[]`|An array of stream hashes.|


### getGasLimitForHooks

Gets the gas limit for hooks.


```solidity
function getGasLimitForHooks() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The gas limit for hooks.|


### getStreamHash

Computes the hash of a stream from the streamer, recipient, token addresses and a string tag.


```solidity
function getStreamHash(
    address _streamer,
    address _recipient,
    address _token,
    string calldata _tag
)
    public
    pure
    returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamer`|`address`|The address of the stream creator.|
|`_recipient`|`address`|The address of the stream recipient.|
|`_token`|`address`|The address of the token.|
|`_tag`|`string`|Salt for stream creation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The hash of the stream.|


### getAmountToCollectFromStreamAndFeeToPay

Gets the amount withdrawable from the stream as well as the fee amount.


```solidity
function getAmountToCollectFromStreamAndFeeToPay(bytes32 _streamHash) public view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of funds withdrawable from the stream.|
|`<none>`|`uint256`|The fee amount applied to the withdrawable funds.|


