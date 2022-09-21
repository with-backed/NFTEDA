// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "src/ExponentialPriceDecayNFTAuction.sol";
import {SimplePurchaseNFT} from "src/periphery/SimplePurchaseNFT.sol";
import {TestERC721} from "test/mocks/TestERC721.sol";
import {TestERC20} from "test/mocks/TestERC20.sol";
import {PayTooLittlePurchasePeriphery} from "test/mocks/PayTooLittlePurchasePeriphery.sol";

contract ExponentialPriceDecayNFTAuctionTest is Test {
    ExponentialPriceDecayNFTAuction public auctionHouse = new ExponentialPriceDecayNFTAuction();
    ExponentialPriceDecayNFTAuction.Auction auction;
    TestERC721 nft = new TestERC721();
    TestERC20 erc20 = new TestERC20();
    SimplePurchaseNFT purchasePeriphery = new SimplePurchaseNFT();
    uint256 nftId = 1;
    uint256 decay = 0.9e18;
    uint256 secondsInPeriod = 1 days;
    uint256 startPrice = 1e18;
    address purchaser = address(0xb0b);

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

    function setUp() public {
        auction = ExponentialPriceDecayNFTAuction.Auction({
            auctionAssetID: nftId,
            auctionAssetContract: nft,
            perPeriodDecayPercentWad: decay,
            secondsInPeriod: secondsInPeriod,
            startPrice: startPrice,
            paymentAsset: erc20
        });
        nft.mint(address(auctionHouse), nftId);
        auctionHouse.startAuction(auction);

        erc20.mint(purchaser, startPrice);
        vm.prank(purchaser);
        erc20.approve(address(purchasePeriphery), startPrice);
    }

    function testStartAuctionEmitsCorrect() public {
        vm.expectEmit(true, true, true, true);
        auction.auctionAssetID = 2;
        emit StartAuction(
            auctionHouse.auctionID(auction),
            auction.auctionAssetID,
            auction.auctionAssetContract,
            auction.perPeriodDecayPercentWad,
            auction.secondsInPeriod,
            auction.startPrice,
            auction.paymentAsset
            );
        auctionHouse.startAuction(auction);
    }

    function testStartAuctionRevertsIfAlreadyStarted() public {
        vm.expectRevert(ExponentialPriceDecayNFTAuction.AuctionExists.selector);
        auctionHouse.startAuction(auction);
    }

    function testCurrentPrice() public {
        assertEq(auctionHouse.currentPrice(auction), 1e18);
        vm.warp(block.timestamp + 1 days);
        // off by 1, precise 1e17
        assertEq(auctionHouse.currentPrice(auction), 99999999999999999);
        vm.warp(block.timestamp + 1 days);
        // off by 1, precise 1e16
        assertEq(auctionHouse.currentPrice(auction), 9999999999999999);
        vm.warp(block.timestamp + 1 days);
        // off by 1, precise 1e15
        assertEq(auctionHouse.currentPrice(auction), 999999999999999);
    }

    function testCurrentPriceRevertsIfAuctionDoesNotExist() public {
        auction.auctionAssetID = 10;
        vm.expectRevert(ExponentialPriceDecayNFTAuction.InvalidAuction.selector);
        auctionHouse.currentPrice(auction);
    }

    function testPurcahseNFTEmitsEndAuction() public {
        vm.startPrank(purchaser);
        vm.expectEmit(true, true, true, true);
        emit EndAuction(auctionHouse.auctionID(auction), startPrice);
        purchasePeriphery.purchaseNFT(auctionHouse, auction, startPrice);
    }

    function testPurchaseNFTOnlyPaysCurrentPrice() public {
        vm.startPrank(purchaser);
        vm.warp(block.timestamp + 1 days);
        uint256 price = auctionHouse.currentPrice(auction);
        purchasePeriphery.purchaseNFT(auctionHouse, auction, startPrice);
        assertEq(erc20.balanceOf(purchaser), startPrice - price);
    }

    function testPurchaseNFTRevertsIfMaxPriceTooLow() public {
        vm.startPrank(purchaser);
        vm.warp(block.timestamp + 1 days);
        uint256 price = auctionHouse.currentPrice(auction);
        uint256 maxPrice = price - 1;
        vm.expectRevert(
            abi.encodeWithSelector(ExponentialPriceDecayNFTAuction.MaxPriceTooLow.selector, price, maxPrice)
        );
        purchasePeriphery.purchaseNFT(auctionHouse, auction, maxPrice);
    }

    function testPurchaseNFTRevertsIfPaymentAmountTooLow() public {
        vm.startPrank(purchaser);
        purchasePeriphery = new PayTooLittlePurchasePeriphery();
        erc20.approve(address(purchasePeriphery), startPrice);
        vm.expectRevert(
            abi.encodeWithSelector(
                ExponentialPriceDecayNFTAuction.InsufficientPayment.selector, startPrice - 1, startPrice
            )
        );
        purchasePeriphery.purchaseNFT(auctionHouse, auction, startPrice);
    }
}
