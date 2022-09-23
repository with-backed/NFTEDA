// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFTEDA} from "src/NFTEDA.sol";

contract SimpleNFTEDA is NFTEDA {
    mapping(uint256 => uint256) internal _auctionStartTime;

    /// @notice Creates an auction defined by the passed `auction`
    /// @dev assumes the nft being sold is already controlled by the auction contract
    /// @param auction The defintion of the auction
    /// @return id the id of the auction
    function startAuction(Auction calldata auction) external virtual override returns (uint256 id) {
        id = auctionID(auction);

        if (_auctionStartTime[id] != 0) {
            revert AuctionExists();
        }

        _auctionStartTime[id] = block.timestamp;

        _startAuction(id, auction);
    }

    /// @notice purchases the NFT being sold in `auction`, reverts if current auction price exceed maxPrice
    /// @dev Does not "pull" payment but expects payment to be received after safeTransferFrom call.
    /// @dev i.e. does not work if msg.sender is EOA.
    /// @param auction The auction selling the NFT
    /// @param maxPrice The maximum the caller is willing to pay
    /// @param data arbitrary data, passed back to caller, along with the amount to pay, in an encoded CallbackInfo
    function purchaseNFT(Auction calldata auction, uint256 maxPrice, bytes calldata data) external virtual override {
        uint256 id = auctionID(auction);
        uint256 startTime = _auctionStartTime[id];

        if (startTime == 0) {
            revert InvalidAuction();
        }
        uint256 price = _currentPrice(startTime, auction);

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _purchaseNFT(id, price, auction, data);
    }

    function auctionStartTime(uint256 id) public view override returns (uint256) {
        return _auctionStartTime[id];
    }
}
