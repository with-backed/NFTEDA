// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFTEDA} from "src/NFTEDA.sol";

contract NFTEDAStarterIncentive is NFTEDA {
    struct AuctionState{
        uint96 startTime;
        address auctionStarter;
    }
    
    /// @notice The percent discount the creator of an auction should 
    /// receive, compared to the current price
    /// 1e18 = 100%
    uint256 public immutable auctionCreatorDiscountPercentWad;

    constructor(uint256 _auctionCreatorDiscountPercentWad) {
        auctionCreatorDiscountPercentWad = _auctionCreatorDiscountPercentWad;
    }

    /// @notice Creates an auction defined by the passed `auction`
    /// @dev assumes the nft being sold is already controlled by the auction contract
    /// @param auction The defintion of the auction
    /// @return id the id of the auction
    function startAuction(Auction calldata auction) external virtual override returns (uint256 id) {
        id = auctionID(auction);

        if (auctionStartTime(id) != 0) {
            revert AuctionExists();
        }

        auctionState[id].startTime = block.timestamp;
        // auctionState[id].creator = msg.sender;

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
}