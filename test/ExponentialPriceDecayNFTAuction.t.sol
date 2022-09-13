// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "../src/ExponentialPriceDecayNFTAuction.sol";

contract ExponentialPriceDecayNFTAuctionTest is Test {
    ExponentialPriceDecayNFTAuction public auctionHouse = new ExponentialPriceDecayNFTAuction();

    function setUp() public {}

    function testCurrentPrice() public {
        ExponentialPriceDecayNFTAuction.Auction memory auction = ExponentialPriceDecayNFTAuction.Auction({
            auctionAssetID: 0,
            auctionAssetContract: ERC721(address(0)),
            perPeriodDecayPercentWad: uint256(0.9e18),
            secondsInPeriod: 1 days,
            startPrice: 1e18,
            paymentAsset: ERC20(address(0))
        });

        auctionHouse.startAuction(auction);
        vm.warp(block.timestamp + 1 days);
        // off by 1, precise 1e17
        assertEq(auctionHouse.currentPrice(auction), 99999999999999999);
    }
}
