// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {FullMath} from "fullrange/libraries/FullMath.sol";
import {TickMath} from "fullrange/libraries/TickMath.sol";

contract ExponentialPriceDecayNFTAuction {
    struct Auction {
        uint256 auctionAssetID;
        ERC721 auctionAssetContract;
        uint256 perPeriodDecay;
        uint256 secondsInPeriod;
        uint256 startPrice;
        ERC20 paymentAsset;
    }

    event StartAuction(
        uint256 indexed auctionID,
        uint256 indexed auctionAssetID,
        ERC721 indexed auctionAssetContract,
        uint256 perPeriodDecay,
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
            auction.perPeriodDecay,
            auction.secondsInPeriod,
            auction.startPrice,
            auction.paymentAsset
            );
    }

    error InvalidAuction();
    error InsufficientPayment();

    function purchaseNFT(Auction calldata auction, address sendTo, bytes calldata data) external {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime[id];

        if (startTime == 0) {
            revert InvalidAuction();
        }

        uint256 beforeBalance = auction.paymentAsset.balanceOf(address(this));
        uint256 price = currentPrice(auction);
        delete auctionStartTime[id];
        auction.auctionAssetContract.safeTransferFrom(address(this), sendTo, auction.auctionAssetID, data);

        if (auction.paymentAsset.balanceOf(address(this)) - price < beforeBalance) {
            revert InsufficientPayment();
        }
    }

    function currentPrice(Auction calldata auction) public view returns (uint256) {
        uint256 secondsElapsed = block.timestamp - auctionStartTime[auctionID(auction)];
        uint256 ratio = FixedPointMathLib.divWadDown(secondsElapsed, auction.secondsInPeriod);
        int256 price = int256(auction.startPrice)
            * FixedPointMathLib.powWad(int256(FixedPointMathLib.WAD - auction.perPeriodDecay), int256(ratio));
        return (uint256(price) / FixedPointMathLib.WAD);
    }

    function currentPriceUniswap(Auction calldata auction) public returns (uint256) {
        int256 secondsPassed = int256(block.timestamp - auctionStartTime[auctionID(auction)]);
        // manual for now, should compute and save on auction creation
        int24 endTick = -46055;
        unchecked {
            uint256 sqrtPrice =
                TickMath.getSqrtRatioAtTick(int24(endTick * secondsPassed / int256(auction.secondsInPeriod)));
            return FullMath.mulDiv(auction.startPrice, sqrtPrice, 1 << 96);
        }
    }

    function _endTick(uint256 perPeriodDecay) internal returns (int24) {
        uint256 remaining = FixedPointMathLib.WAD - perPeriodDecay;
        unchecked {
            return TickMath.getTickAtSqrtRatio(uint160((remaining * (1 << 96)) / FixedPointMathLib.WAD));
        }
    }

    function auctionID(Auction calldata auction) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }
}
