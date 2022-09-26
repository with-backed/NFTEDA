// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {EDAPrice} from "src/libraries/EDAPrice.sol";

contract NFTPriceTest is Test {
    function testCurrentPrice() public {
        uint256 price = EDAPrice.currentPrice(1e18, 0, 1 days, 0.9e18);
        assertEq(price, 1e18);
        price = EDAPrice.currentPrice(1e18, 1 days, 1 days, 0.9e18);
        // off by 1, precise 1e17
        assertEq(price, 1e17 - 1);
        price = EDAPrice.currentPrice(1e18, 2 days, 1 days, 0.9e18);
        // off by 1, precise 1e16
        assertEq(price, 1e16 - 1);
        price = EDAPrice.currentPrice(1e18, 3 days, 1 days, 0.9e18);
        // off by 1, precise 1e15
        assertEq(price, 1e15 - 1);
        price = EDAPrice.currentPrice(1e18, 4 days, 1 days, 0.9e18);
        // off by 1, precise 1e14
        assertEq(price, 1e14 - 1);
        price = EDAPrice.currentPrice(1e18, 10 days, 1 days, 0.9e18);
        // off by 1, precise 1e8
        assertEq(price, 1e8 - 1);
    }
}
