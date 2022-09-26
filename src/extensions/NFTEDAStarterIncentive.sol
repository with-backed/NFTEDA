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
    uint256 public immutable auctionCreatorDiscountPercentWad;
    uint256 internal immutable _pricePercentAfterDiscount;

    mapping(uint256 => AuctionState) public auctionState;

    constructor(uint256 _auctionCreatorDiscountPercentWad) {
        auctionCreatorDiscountPercentWad = _auctionCreatorDiscountPercentWad;
        _pricePercentAfterDiscount = FixedPointMathLib.WAD - _auctionCreatorDiscountPercentWad;
    }

    /// @notice purchases the NFT being sold in `auction`, reverts if current auction price exceed maxPrice
    /// @dev Does not "pull" payment but expects payment to be received after safeTransferFrom call.
    /// @dev i.e. does not work if msg.sender is EOA.
    /// @param auction The auction selling the NFT
    /// @param maxPrice The maximum the caller is willing to pay
    /// @param data arbitrary data, passed back to caller, along with the amount to pay, in an encoded CallbackInfo
    function purchaseNFT(Auction calldata auction, uint256 maxPrice, bytes calldata data) external virtual override {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionState[id].startTime;
        address starter = auctionState[id].starter;

        if (startTime == 0) {
            revert InvalidAuction();
        }
        uint256 price = _currentPrice(startTime, auction);

        if (msg.sender == starter) {
            price = FixedPointMathLib.mulWadUp(price, _pricePercentAfterDiscount);
        }

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _purchaseNFT(id, price, auction, data);
    }

    function auctionStartTime(uint256 id) public view override returns (uint256) {
        return auctionState[id].startTime;
    }

    function _setAuctionStartTime(uint256 id) internal override {
        auctionState[id] = AuctionState({
            startTime: uint96(block.timestamp),
            starter: msg.sender
        });
    }
}
