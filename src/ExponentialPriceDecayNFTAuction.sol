// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract ExponentialPriceDecayNFTAuction {
    struct Auction {
        uint256 auctionAssetID;
        ERC721 auctionAssetContract;
        // FixedPointMathLib.WAD = 100%
        uint256 perPeriodDecayPercentWad;
        uint256 secondsInPeriod;
        uint256 startPrice;
        ERC20 paymentAsset;
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

    event EndAuction(uint256 indexed auctionID);

    mapping(uint256 => uint256) auctionStartTime;

    function startAuction(Auction calldata auction) external returns (uint256 id) {
        id = auctionID(auction);

        auctionStartTime[id] = block.timestamp;

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

    error InvalidAuction();
    error InsufficientPayment();
    error MaxPriceTooLow();

    function purchaseNFT(Auction calldata auction, uint256 maxPrice, bytes calldata data) external {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime[id];

        if (startTime == 0) {
            revert InvalidAuction();
        }

        uint256 beforeBalance = auction.paymentAsset.balanceOf(address(this));
        uint256 price = currentPrice(auction);

        // price changes over time and the price the caller pays
        // will depend on when their tx is included in a block
        // passing a max price offers a nice sanity check on
        // what you pay
        if (price > maxPrice) {
            revert MaxPriceTooLow();
        }

        delete auctionStartTime[id];

        // We effectively use this as a callback, via the on receive handler,
        // allowing the buyer to receive the NFT first and then provide payment,
        // meaning they could sell the NFT in some arb to provide payment.
        // TBD if we should have a dedicated callback method that callers should implement.
        auction.auctionAssetContract.safeTransferFrom(address(this), msg.sender, auction.auctionAssetID, data);

        if (auction.paymentAsset.balanceOf(address(this)) - price < beforeBalance) {
            revert InsufficientPayment();
        }

        emit EndAuction(id);
    }

    function currentPrice(Auction calldata auction) public view returns (uint256) {
        uint256 secondsElapsed = block.timestamp - auctionStartTime[auctionID(auction)];
        uint256 ratio = FixedPointMathLib.divWadDown(secondsElapsed, auction.secondsInPeriod);
        uint256 percentWadRemainingPerPeriod = FixedPointMathLib.WAD - auction.perPeriodDecayPercentWad;
        int256 multiplier = FixedPointMathLib.powWad(toInt256(percentWadRemainingPerPeriod), toInt256(ratio));
        // casting to uint256 is safe because percentWadRemainingPerPeriod is non negative
        uint256 price = auction.startPrice * uint256(multiplier);
        return (price / FixedPointMathLib.WAD);
    }

    function auctionID(Auction calldata auction) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2 ** 255);
        z = int256(y);
    }
}
