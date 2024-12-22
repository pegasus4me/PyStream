# BaseVault
[Git Source](https://github.com/mgnfy-view/pystreams-monorepo/blob/c2bc4b1569db02cc5d60e647d96e72dffac4c56e/src/utils/BaseVault.sol)

**Inherits:**
Ownable, [IHooks](/src/interfaces/IHooks.sol/interface.IHooks.md)

**Author:**
mgnfy-view.

This base vault implementation can be extended by developers to build various
plugins on top of the payStreams protocol using hooks.


## Functions
### constructor


```solidity
constructor() Ownable(msg.sender);
```

### afterStreamCreated


```solidity
function afterStreamCreated(bytes32 _streamHash) external virtual;
```

### beforeFundsCollected


```solidity
function beforeFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external virtual;
```

### afterFundsCollected


```solidity
function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external virtual;
```

### beforeStreamUpdated


```solidity
function beforeStreamUpdated(bytes32 _streamHash) external virtual;
```

### afterStreamUpdated


```solidity
function afterStreamUpdated(bytes32 _streamHash) external virtual;
```

### beforeStreamPaused


```solidity
function beforeStreamPaused(bytes32 _streamHash) external virtual;
```

### afterStreamPaused


```solidity
function afterStreamPaused(bytes32 _streamHash) external virtual;
```

### beforeStreamUnPaused


```solidity
function beforeStreamUnPaused(bytes32 _streamHash) external virtual;
```

### afterStreamUnPaused


```solidity
function afterStreamUnPaused(bytes32 _streamHash) external virtual;
```

### beforeStreamClosed


```solidity
function beforeStreamClosed(bytes32 _streamHash) external virtual;
```

### afterStreamClosed


```solidity
function afterStreamClosed(bytes32 _streamHash) external virtual;
```

### collectFunds

Allows the owner to collect funds from the vault.


```solidity
function collectFunds(address _token, uint256 _amount, address _to) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|The token to be collected.|
|`_amount`|`uint256`|The amount of token to be collected.|
|`_to`|`address`|The recipient of the funds.|


## Events
### FundsCollected

```solidity
event FundsCollected(address indexed token, uint256 indexed amount, address indexed to);
```

## Errors
### BaseVault__InsufficientFunds

```solidity
error BaseVault__InsufficientFunds();
```

