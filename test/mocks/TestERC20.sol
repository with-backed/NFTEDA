// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract TestERC20 is ERC20("Test", "TEST", 18) {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
