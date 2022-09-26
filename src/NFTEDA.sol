// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeCast} from "v3-core/contracts/libraries/SafeCast.sol";

import {EDAPrice} from "src/libraries/EDAPrice.sol";

abstract contract NFTEDA {
    /// @notice struct containing all auction info
    /// @dev this struct is never stored, only a hash of it
    struct Auction {
        // the nft token id
        uint256 auctionAssetID;
        // the nft contract address
        ERC721 auctionAssetContract;
        // How much the auction price should decay in each period
        // expressed as percent scaled by 1e18, i.e. 1e18 = 100%
        uint256 perPeriodDecayPercentWad;
        // the number of seconds in the period over which perPeriodDecay occurs
        uint256 secondsInPeriod;
        // the auction start price
        uint256 startPrice;
        // the payment asset
        ERC20 paymentAsset;
    }

    /// @notice this struct is encoded and passed to the caller of purchaseNFT
    struct CallbackInfo {
        // the current auction price, i.e. the amount to pay
        uint256 price;
        // any data the caller paseed to purchaseNFT
        bytes passedData;
    }

    event StartAuction(
        uint256 indexed auctionID,
        uint256 indexed auctionAssetID,
        ERC721 indexed auctionAssetContract,
        uint256 perPeriodDecayPercentWad,
        uint256 secondsInPeriod,
        uint256 startPrice,
        ERC20 paymentAsset
    );
    event EndAuction(uint256 indexed auctionID, uint256 price);

    error AuctionExists();
    error InvalidAuction();
    /// @param received The amount of payment received
    /// @param expected The expected payment amount
    error InsufficientPayment(uint256 received, uint256 expected);
    /// @param currentPrice The current auction price
    /// @param maxPrice The passed max price the purchaser is willing to pay
    error MaxPriceTooLow(uint256 currentPrice, uint256 maxPrice);

    /// @notice Creates an auction defined by the passed `auction`
    /// @dev assumes the nft being sold is already controlled by the auction contract
    /// @param auction The defintion of the auction
    /// @return id the id of the auction
    function startAuction(Auction calldata auction) external virtual returns (uint256 id) {
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
    function purchaseNFT(Auction calldata auction, uint256 maxPrice) external virtual;

    /// @notice Returns the current price of the passed auction, reverts if no such auction exists
    /// @param auction The auction for which the caller wants to know the current price
    /// @return price the current amount required to purchase the NFT being sold in this auction
    function currentPrice(Auction calldata auction) public view virtual returns (uint256) {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime(id);
        if (startTime == 0) {
            revert InvalidAuction();
        }

        return _currentPrice(startTime, auction);
    }

    /// @notice Returns a uint256 used to identify the auction
    /// @dev Derived from the auction. Identitical auctions cannot exist simultaneously
    /// @param auction The auction to get an ID for
    /// @return id the id of this auction
    function auctionID(Auction calldata auction) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }

    function auctionStartTime(uint256 id) public view virtual returns (uint256);

    /// @notice purchases the NFT being sold in `auction`
    /// @dev Does not "pull" payment but expects payment to be received after safeTransferFrom call.
    /// @dev i.e. does not work if msg.sender is EOA.
    /// @param id The id of the auction
    /// @param auction The auction selling the NFT
    /// @param price The price the caller is expected to pay
    function _purchaseNFT(uint256 id, uint256 price, Auction calldata auction) internal virtual {
        auction.auctionAssetContract.safeTransferFrom(
            address(this),
            msg.sender,
            auction.auctionAssetID
        );

        auction.paymentAsset.transferFrom(msg.sender, address(this), price);

        emit EndAuction(id, price);
    }

    function _setAuctionStartTime(uint256 id) internal virtual;

    /// @notice Returns the current price of the passed auction, reverts if no such auction exists
    /// @dev startTime is passed, optimized for cases where the auctionId has already been computed
    /// @dev and startTime looked it up
    /// @param startTime The start time of the auction
    /// @param auction The auction for which the caller wants to know the current price
    /// @return price the current amount required to purchase the NFT being sold in this auction
    function _currentPrice(uint256 startTime, Auction calldata auction) internal view virtual returns (uint256) {
        return EDAPrice.currentPrice(
            auction.startPrice, block.timestamp - startTime, auction.secondsInPeriod, auction.perPeriodDecayPercentWad
        );
    }
}
