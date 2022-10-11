// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {NFTEDA} from "src/NFTEDA.sol";

contract NFTEDAStarterIncentive is NFTEDA {
    struct AuctionState{
        uint96 startTime;
        address starter;
    }

    /// @notice The percent discount the creator of an auction should
    /// receive, compared to the current price
    /// 1e18 = 100%
    uint256 public auctionCreatorDiscountPercentWad;
    uint256 internal _pricePercentAfterDiscount;

    mapping(uint256 => AuctionState) public auctionState;

    constructor(uint256 _auctionCreatorDiscountPercentWad) {
        _setCreatorDiscount(_auctionCreatorDiscountPercentWad);
    }

    function auctionStartTime(uint256 id) public view virtual override returns (uint256) {
        return auctionState[id].startTime;
    }

    function _setAuctionStartTime(uint256 id) internal virtual override {
        auctionState[id] = AuctionState({
            startTime: uint96(block.timestamp),
            starter: msg.sender
        });
    }

    function _clearAuctionState(uint256 id) internal virtual override {
        delete auctionState[id];
    }

    function _currentPrice(uint256 startTime, Auction calldata auction) internal view virtual override returns (uint256) {
        uint256 price = super._currentPrice(startTime, auction);

        /// TODO having to recompute the ID here on the purchaseNFT call path is not idea
        /// but it saves us copying all the boilter plate. Maybe change later.
        if (msg.sender == auctionState[auctionID(auction)].starter) {
            price = FixedPointMathLib.mulWadUp(price, _pricePercentAfterDiscount);
        }

        return price;
    }

    function _setCreatorDiscount(uint256 _auctionCreatorDiscountPercentWad) internal virtual {
        auctionCreatorDiscountPercentWad = _auctionCreatorDiscountPercentWad;
        _pricePercentAfterDiscount = FixedPointMathLib.WAD - _auctionCreatorDiscountPercentWad;
    }
}
