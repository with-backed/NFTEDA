// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "../src/ExponentialPriceDecayNFTAuction.sol";

contract ExponentialPriceDecayNFTAuctionTest is Test {
    ExponentialPriceDecayNFTAuction public auctionHouse = new ExponentialPriceDecayNFTAuction();

    function setUp() public {
    }

    function testCurrentPrice() public {
        ExponentialPriceDecayNFTAuction.Auction memory auction = ExponentialPriceDecayNFTAuction.Auction({
            auctionAssetID: 0,
            auctionAssetContract: ERC721(address(0)),
            perSecondDecayWAD: uint256(0.1e17) / 1 days,
            startPrice: 1e18,
            paymentAsset: ERC20(address(0))
        });
        emit log_int(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)));
        emit log_int(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)) * 1 days);
        emit log_int(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)) * 1 days / 1e18);
        emit log_int(FixedPointMathLib.expWad(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)) * int256(1 days) / int256(1e18)));
        emit log_int(int256(1e18) * (FixedPointMathLib.expWad(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)) * 1 days / 1e18)));
        emit log_int(int256(1e18) * (FixedPointMathLib.expWad(FixedPointMathLib.lnWad(int256(auction.perSecondDecayWAD)) * 2 days / 1e18)) / 1e19);
        emit log_string("FixedPointMathLib.powWad(2, 50)");
        emit log_string("=>");
        emit log_int(FixedPointMathLib.powWad(2, 50));
        emit log_string("FixedPointMathLib.powWad(50, 50)");
        emit log_string("=>");
        emit log_int(FixedPointMathLib.powWad(50, 50));
        emit log_string("FixedPointMathLib.powWad(0.9e18, 100)");
        emit log_string("=>");
        emit log_int(2e18 * FixedPointMathLib.powWad(1, 10) / 1e18);

        uint256 ratio = FixedPointMathLib.divWadDown(30, 1 days);
        uint256 change = 0.1e18;// * ratio / 1e18;
        emit log_uint(change);
        // emit log_int(2e18 * FixedPointMathLib.powWad(int256(change), int256(ratio)) / 1e18);
        // emit log_int(FixedPointMathLib.powWad(2e20, 4) / 1e18);
        // emit log_uint(FixedPointMathLib.rpow(90, 1 days, 100));
        // emit log_uint(auction.perSecondDecayWAD);
        // emit log_int(FixedPointMathLib.expWad(1));
        // emit log_int(1e18 * FixedPointMathLib.powWad(int256(auction.perSecondDecayWAD), 1) / 1e18);
        // emit log_int(FixedPointMathLib.powWad(int256(auction.perSecondDecayWAD), 2 ));
        // emit log_int(FixedPointMathLib.powWad(int256(auction.perSecondDecayWAD), 10 ));
        // emit log_uint(FixedPointMathLib.mulWadUp(1e18, uint256(FixedPointMathLib.powWad(int256(auction.perSecondDecayWAD), 10 days))));
        // auctionHouse.startAuction(auction);
        // emit log_uint(auctionHouse.currentPrice(auction));
        // vm.warp(block.timestamp + 1 days);
        // emit log_uint(auctionHouse.currentPrice(auction));

    }
}
