// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {FullMath} from "fullrange/libraries/FullMath.sol";
import {TickMath} from "fullrange/libraries/TickMath.sol";

import "../src/ExponentialPriceDecayNFTAuction.sol";

contract ExponentialPriceDecayNFTAuctionTest is Test {
    ExponentialPriceDecayNFTAuction public auctionHouse = new ExponentialPriceDecayNFTAuction();

    function setUp() public {}

    function testCurrentPrice() public {
        ExponentialPriceDecayNFTAuction.Auction memory auction = ExponentialPriceDecayNFTAuction.Auction({
            auctionAssetID: 0,
            auctionAssetContract: ERC721(address(0)),
            perPeriodDecay: uint256(0.9e18),
            secondsInPeriod: 1 days,
            startPrice: 1e18,
            paymentAsset: ERC20(address(0))
        });

        auctionHouse.startAuction(auction);
        vm.warp(block.timestamp + 1 days);
        emit log_named_uint("Precise", 1e17);
        emit log_named_uint("Solmate", auctionHouse.currentPrice(auction));
        emit log_named_uint("Uniswap", auctionHouse.currentPriceUniswap(auction));
    }
}
