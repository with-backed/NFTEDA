// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {EDAPrice, FixedPointMathLib} from "src/libraries/EDAPrice.sol";

contract EDAPriceTest is Test {
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

    function testFuzz(
        uint256 startPrice,
        uint256 secondsElapsed,
        uint256 secondsInPeriod,
        uint256 perPeriodDecayPercentWad
    ) public {
        vm.assume(secondsElapsed < type(uint256).max / 1e18);
        vm.assume(secondsInPeriod > 0);
        vm.assume(perPeriodDecayPercentWad < 1e18);
        uint256 ratio = FixedPointMathLib.divWadDown(secondsElapsed, secondsInPeriod);
        uint256 percentWadRemainingPerPeriod = FixedPointMathLib.WAD - perPeriodDecayPercentWad;
        vm.assume(uint256(FixedPointMathLib.lnWad(type(int256).max)) >= ratio);
        vm.assume(
            ratio == 0 || percentWadRemainingPerPeriod < uint256(FixedPointMathLib.lnWad(type(int256).max)) / ratio
        );
        int256 multiplier = FixedPointMathLib.powWad(int256(percentWadRemainingPerPeriod), int256(ratio));
        vm.assume(startPrice <= type(uint256).max / uint256(multiplier));
        EDAPrice.currentPrice(startPrice, secondsElapsed, secondsInPeriod, perPeriodDecayPercentWad);
    }
}
