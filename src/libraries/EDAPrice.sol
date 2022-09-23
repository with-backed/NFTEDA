// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeCast} from "v3-core/contracts/libraries/SafeCast.sol";

library EDAPrice {
    using SafeCast for uint256;

    function currentPrice(
        uint256 startPrice,
        uint256 secondsElapsed,
        uint256 secondsInPeriod,
        uint256 perPeriodDecayPercentWad
    ) internal view returns (uint256) {
        uint256 ratio = FixedPointMathLib.divWadDown(secondsElapsed, secondsInPeriod);
        uint256 percentWadRemainingPerPeriod = FixedPointMathLib.WAD - perPeriodDecayPercentWad;
        int256 multiplier = FixedPointMathLib.powWad(percentWadRemainingPerPeriod.toInt256(), ratio.toInt256());
        // casting to uint256 is safe because percentWadRemainingPerPeriod is non negative
        uint256 price = startPrice * uint256(multiplier);
        return (price / FixedPointMathLib.WAD);
    }
}
