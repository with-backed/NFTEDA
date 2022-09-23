// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "src/extensions/NFTEDAStarterIncentive.sol";
import {NFTEDATest} from 'test/NFTEDA.t.sol';

contract NFTEDAStarterIncentiveTest is NFTEDATest {
    uint256 discount = 0.1e18;

    function _createAuctionContract() internal override {
        auctionContract = new NFTEDAStarterIncentive(discount);
    }

    function testCreatorCanPayLowerPrice() public {
        nft.mint(address(auctionContract), nftId + 1);
        auction.auctionAssetID = nftId + 1;
        vm.prank(address(purchasePeriphery));
        auctionContract.startAuction(auction);
        uint256 price = auctionContract.currentPrice(auction);
        uint256 discountPrice = FixedPointMathLib.mulWadUp(price, FixedPointMathLib.WAD - discount);
        (, address starter) = NFTEDAStarterIncentive(address(auctionContract)).auctionState(auctionContract.auctionID(auction));
        erc20.mint(address(this), discountPrice);
        erc20.approve(address(purchasePeriphery), discountPrice);
        purchasePeriphery.purchaseNFT(auctionContract, auction, discountPrice);
    }
}
