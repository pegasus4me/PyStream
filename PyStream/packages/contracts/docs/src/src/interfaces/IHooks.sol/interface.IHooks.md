# IHooks
[Git Source](https://github.com/mgnfy-view/pystreams-monorepo/blob/c2bc4b1569db02cc5d60e647d96e72dffac4c56e/src/interfaces/IHooks.sol)


## Functions
### afterStreamCreated


```solidity
function afterStreamCreated(bytes32 _streamHash) external;
```

### beforeFundsCollected


```solidity
function beforeFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external;
```

### afterFundsCollected


```solidity
function afterFundsCollected(bytes32 _streamHash, uint256 _amount, uint256 _feeAmount) external;
```

### beforeStreamUpdated


```solidity
function beforeStreamUpdated(bytes32 _streamHash) external;
```

### afterStreamUpdated


```solidity
function afterStreamUpdated(bytes32 _streamHash) external;
```

### beforeStreamPaused


```solidity
function beforeStreamPaused(bytes32 _streamHash) external;
```

### afterStreamPaused


```solidity
function afterStreamPaused(bytes32 _streamHash) external;
```

### beforeStreamUnPaused


```solidity
function beforeStreamUnPaused(bytes32 _streamHash) external;
```

### afterStreamUnPaused


```solidity
function afterStreamUnPaused(bytes32 _streamHash) external;
```

### beforeStreamClosed


```solidity
function beforeStreamClosed(bytes32 _streamHash) external;
```

### afterStreamClosed


```solidity
function afterStreamClosed(bytes32 _streamHash) external;
```

