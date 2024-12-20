// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) { }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
