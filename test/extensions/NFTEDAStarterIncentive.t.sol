// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "src/extensions/NFTEDAStarterIncentive.sol";
import {NFTEDATest} from 'test/NFTEDA.t.sol';
import {TestNFTEDAStarterIncentive} from "test/mocks/TestNFTEDAStarterIncentive.sol";

contract NFTEDAStarterIncentiveTest is NFTEDATest {
    uint256 discount = 0.1e18;

    function _createAuctionContract() internal override {
        auctionContract = new TestNFTEDAStarterIncentive(discount);
    }

    function testStartAuctionSavesStarter() public {
        vm.warp(1 weeks);
        auction.auctionAssetID = 2;
        auctionContract.startAuction(auction);
        (uint256 startTime, address starter) = NFTEDAStarterIncentive(address(auctionContract)).auctionState(auctionContract.auctionID(auction));
        assertEq(startTime, 1 weeks);
        assertEq(starter, address(this));
    }

    function testPurchaseNFTAllowsStarterLowerPrice() public {
        vm.startPrank(purchaser);
        uint256 price = auctionContract.currentPrice(auction);
        uint256 discountPrice = FixedPointMathLib.mulWadUp(price, FixedPointMathLib.WAD - discount);
        nft.mint(address(auctionContract), nftId + 1);
        auction.auctionAssetID = nftId + 1;
        auctionContract.startAuction(auction);
        erc20.mint(address(this), discountPrice);
        erc20.approve(address(auctionContract), discountPrice);
        auctionContract.purchaseNFT(auction, discountPrice);
    }

    function testPurchaseNFTClearsState() public {
        vm.prank(purchaser);
        auctionContract.purchaseNFT(auction, startPrice);
        (uint256 startTime, address starter) = NFTEDAStarterIncentive(address(auctionContract)).auctionState(auctionContract.auctionID(auction));
        assertEq(startTime, 0);
        assertEq(starter, address(0));
    }
}
