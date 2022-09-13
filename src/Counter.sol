// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract ExponentialPriceDecayNFTAuction {
    struct Auction {
        uint256 auctionAssetID;
        ERC721 auctionAssetContract;
        uint256 perSecondDecayWAD;
        uint256 startPrice;
        ERC20 paymentAsset;
    }

    event StartAuction(
        uint256 indexed auctionID,
        uint256 indexed auctionAssetID,
        ERC721 indexed auctionAssetContract,
        uint256 perSecondDecayWAD,
        uint256 startPrice,
        ERC20 paymentAsset
    );

    event EndAuction(uint256 indexed auctionID);

    mapping(uint256 => uint256) auctionStartTime;

    function startAuction(Auction calldata auction) external returns (uint256 id) {
        id = auctionID(auction);

        auctionStartTime[id] = block.timestamp;

        emit StartAuction(id, auction.auctionAssetID, auction.auctionAssetContract, auction.perSecondDecayWAD, auction.startPrice, auction.paymentAsset);
    }

    error InvalidAuction();

    function purchaseNFT(Auction calldata auction) external {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime[id];

        if (startTime == 0){
            revert InvalidAuction();
        }

        uint256 beforeBalance = auction.paymentAsset.balanceOf(address(this));

        

    }

    function currentPrice(Auction calldata auction) pure public returns (uint256) {
        return auction.startPrice
        * auction.perSecondDecayWAD
    }

    function auctionID(Auction calldata auction) pure public returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }
}
