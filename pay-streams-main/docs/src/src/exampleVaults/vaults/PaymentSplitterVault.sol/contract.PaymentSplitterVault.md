# PaymentSplitterVault
[Git Source](https://github.com/mgnfy-view/pystreams-monorepo/blob/c2bc4b1569db02cc5d60e647d96e72dffac4c56e/src/exampleVaults/vaults/PaymentSplitterVault.sol)

**Inherits:**
[BaseVault](/src/utils/BaseVault.sol/abstract.BaseVault.md)

**Author:**
mgnfy-view.

A payment splitter vault that splits any streamed payment among a
list of recipients based on their assigned weights.


## State Variables
### s_payStreams

```solidity
address private s_payStreams;
```


### s_recipients

```solidity
address[] private s_recipients;
```


### s_weights

```solidity
uint256[] private s_weights;
```


### s_totalWeight

```solidity
uint256 private s_totalWeight;
```


## Functions
### onlyPayStreams


```solidity
modifier onlyPayStreams();
```

### constructor

Initializes the vault.


```solidity
constructor(address _payStreams, address[] memory _recipients, uint256[] memory _weights);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_payStreams`|`address`|The address of the payStreams contract.|
|`_recipients`|`address[]`|A list of recipients of the streamed amount.|
|`_weights`|`uint256[]`|Assigned weight to each recipient in the list.|


### afterFundsCollected

Once funds have been received by this vault, this function is invoked by the
payStreams contract to split the streamed funds among multiple recipients based on their weight.


```solidity
function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256) external override onlyPayStreams;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_streamHash`|`bytes32`|The hash of the stream.|
|`_amount`|`uint256`|The amount to received from stream.|
|`<none>`|`uint256`||


### updateRecipientAndWeightsList

Allows the owner to update the recipient and the weights list.


```solidity
function updateRecipientAndWeightsList(address[] memory _recipients, uint256[] memory _weights) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipients`|`address[]`|The new list of recipients.|
|`_weights`|`uint256[]`|The weights assigned to each recipient.|


### getPayStreams

Gets the payStreams contract address.


```solidity
function getPayStreams() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The payStreams contract address.|


### getRecipients

Gets the recipients list.


```solidity
function getRecipients() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|The recipients list.|


### getWeights

Gets the weights list.


```solidity
function getWeights() external view returns (uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|The weights list.|


### getTotalWeight

Gets the total weight based on the weights list.


```solidity
function getTotalWeight() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total weight.|


## Events
### PaymentSplit

```solidity
event PaymentSplit(address[] indexed recipients, uint256[] indexed amounts);
```

### RecipientAndWeightsListUpdated

```solidity
event RecipientAndWeightsListUpdated(address[] indexed recipients, uint256[] indexed weights);
```

## Errors
### PaymentSplitterVault__ArrayLengthMismatch

```solidity
error PaymentSplitterVault__ArrayLengthMismatch();
```

### PaymentSplitterVault__NotPayStream

```solidity
error PaymentSplitterVault__NotPayStream();
```

