// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {NFTEDA} from "src/NFTEDA.sol";

contract SimplePurchaseNFT is ERC721TokenReceiver {
    /// @notice used to guard onERC721Received
    /// only has a non 0 value during a transaction
    /// used to only accept NFTs from the auction contract being called
    /// in the current tx
    NFTEDA currentAuctionContract;

    error WrongFrom();

    /// @notice Purchases the NFT being sold in auction by auctionContract
    /// @param auctionContract the NFTEDA contract selling the NFT
    /// @param auction the details of the auction
    /// @param maxPrice the maximum the caller is willing to pay
    function purchaseNFT(NFTEDA auctionContract, NFTEDA.Auction calldata auction, uint256 maxPrice) external {
        currentAuctionContract = auctionContract;
        auctionContract.purchaseNFT(auction, maxPrice);
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

        (NFTEDA.CallbackInfo memory info) = abi.decode(data, (NFTEDA.CallbackInfo));
        (address payer, ERC20 asset) = abi.decode(info.passedData, (address, ERC20));

        delete currentAuctionContract;

        asset.transferFrom(payer, from, info.price);

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
