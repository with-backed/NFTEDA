// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeCast} from "v3-core/contracts/libraries/SafeCast.sol";

import {INFTEDA} from "src/interfaces/INFTEDA.sol";
import {EDAPrice} from "src/libraries/EDAPrice.sol";

abstract contract NFTEDA is INFTEDA {
    error AuctionExists();
    error InvalidAuction();
    /// @param received The amount of payment received
    /// @param expected The expected payment amount
    error InsufficientPayment(uint256 received, uint256 expected);
    /// @param currentPrice The current auction price
    /// @param maxPrice The passed max price the purchaser is willing to pay
    error MaxPriceTooLow(uint256 currentPrice, uint256 maxPrice);

    /// @inheritdoc INFTEDA
    function currentPrice(Auction calldata auction) public view virtual returns (uint256) {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime(id);
        if (startTime == 0) {
            revert InvalidAuction();
        }

        return _currentPrice(id, startTime, auction);
    }

    /// @inheritdoc INFTEDA
    function auctionID(Auction memory auction) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }

    /// @inheritdoc INFTEDA
    function auctionStartTime(uint256 id) public view virtual returns (uint256);

    /// @notice Creates an auction defined by the passed `auction`
    /// @dev assumes the nft being sold is already controlled by the auction contract
    /// @param auction The defintion of the auction
    /// @return id the id of the auction
    function _startAuction(Auction memory auction) internal virtual returns (uint256 id) {
        id = auctionID(auction);

        if (auctionStartTime(id) != 0) {
            revert AuctionExists();
        }

        _setAuctionStartTime(id);

        emit StartAuction(
            id,
            auction.auctionAssetID,
            auction.auctionAssetContract,
            auction.perPeriodDecayPercentWad,
            auction.secondsInPeriod,
            auction.startPrice,
            auction.paymentAsset
            );
    }

    /// @notice purchases the NFT being sold in `auction`, reverts if current auction price exceed maxPrice
    /// @param auction The auction selling the NFT
    /// @param maxPrice The maximum the caller is willing to pay
    function _purchaseNFT(Auction memory auction, uint256 maxPrice) internal virtual {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime(id);

        if (startTime == 0) {
            revert InvalidAuction();
        }
        uint256 price = _currentPrice(id, startTime, auction);

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _clearAuctionState(id);

        auction.auctionAssetContract.safeTransferFrom(
            address(this),
            msg.sender,
            auction.auctionAssetID
        );

        auction.paymentAsset.transferFrom(msg.sender, address(this), price);

        emit EndAuction(id, price);
    }

    /// @notice Sets the time at which the auction was started
    /// @dev abstracted to a function to allow developer some freedom with how to store auction state
    /// @param id The id of the auction
    function _setAuctionStartTime(uint256 id) internal virtual;

    /// @notice Clears all stored state for the auction
    /// @dev abstracted to a function to allow developer some freedom with how to store auction state
    /// @param id The id of the auction
    function _clearAuctionState(uint256 id) internal virtual;

    /// @notice Returns the current price of the passed auction, reverts if no such auction exists
    /// @dev startTime is passed, optimized for cases where the auctionId has already been computed
    /// @dev and startTime looked it up
    /// @param startTime The start time of the auction
    /// @param auction The auction for which the caller wants to know the current price
    /// @return price the current amount required to purchase the NFT being sold in this auction
    function _currentPrice(uint256 id, uint256 startTime, Auction memory auction) internal view virtual returns (uint256) {
        return EDAPrice.currentPrice(
            auction.startPrice, block.timestamp - startTime, auction.secondsInPeriod, auction.perPeriodDecayPercentWad
        );
    }
}
