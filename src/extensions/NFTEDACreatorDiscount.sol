// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFTEDA} from "src/NFTEDA.sol";

contract NFTEDACreatorDiscount is NFTEDA {
    
    /// @notice The percent discount the creator of an auction should 
    /// receive, compared to the current price
    /// 1e18 = 100%
    uint256 public immutable auctionCreatorDiscountPercentWad;

    constructor(uint256 _auctionCreatorDiscountPercentWad) {
        auctionCreatorDiscountPercentWad = _auctionCreatorDiscountPercentWad;
    }
}