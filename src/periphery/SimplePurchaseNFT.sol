// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {ExponentialPriceDecayNFTAuction} from "src/ExponentialPriceDecayNFTAuction.sol";

contract SimplePurchaseNFT is ERC721TokenReceiver {
    /// @notice used to guard onERC721Received
    /// only has a non 0 value during a transaction
    /// used to only accept NFTs from the auction contract being called
    /// in the current tx
    ExponentialPriceDecayNFTAuction currentAuctionContract;

    error WrongFrom();

    /// @notice Purchases the NFT being sold in auction by auctionContract
    /// @param auctionContract the ExponentialPriceDecayNFTAuction contract selling the NFT
    /// @param auction the details of the auction
    /// @param maxPrice the maximum the caller is willing to pay
    function purchaseNFT(
        ExponentialPriceDecayNFTAuction auctionContract,
        ExponentialPriceDecayNFTAuction.Auction calldata auction,
        uint256 maxPrice
    ) external {
        currentAuctionContract = auctionContract;
        auctionContract.purchaseNFT(auction, maxPrice, abi.encode(msg.sender, auction.paymentAsset));
    }

    function onERC721Received(address from, address, uint256, bytes calldata data)
        external
        virtual
        override
        returns (bytes4)
    {
        if (from != address(currentAuctionContract)) {
            revert WrongFrom();
        }

        (ExponentialPriceDecayNFTAuction.CallbackInfo memory info) =
            abi.decode(data, (ExponentialPriceDecayNFTAuction.CallbackInfo));
        (address payer, ERC20 asset) = abi.decode(info.passedData, (address, ERC20));

        delete currentAuctionContract;

        asset.transferFrom(payer, from, info.price);

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
