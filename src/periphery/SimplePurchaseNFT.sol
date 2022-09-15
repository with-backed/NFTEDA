// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {ExponentialPriceDecayNFTAuction} from "src/ExponentialPriceDecayNFTAuction.sol";

contract SimplePurchaseNFT is ERC721TokenReceiver {
    ExponentialPriceDecayNFTAuction currentAuctionContract;

    function purchaseNFT(
        ExponentialPriceDecayNFTAuction auctionContract,
        ExponentialPriceDecayNFTAuction.Auction calldata auction,
        uint256 maxPrice
    )
        external
    {
        currentAuctionContract = auctionContract;
        auctionContract.purchaseNFT(auction, maxPrice, abi.encode(msg.sender, auction.paymentAsset));
    }

    error WrongCaller();

    function onERC721Received(address from, address, uint256, bytes calldata data) external override returns (bytes4) {
        if (from != address(currentAuctionContract)) {
            revert WrongCaller();
        }

        (ExponentialPriceDecayNFTAuction.CallbackInfo memory info) =
            abi.decode(data, (ExponentialPriceDecayNFTAuction.CallbackInfo));
        (address payer, ERC20 asset) = abi.decode(info.passedData, (address, ERC20));

        delete currentAuctionContract;

        asset.transferFrom(payer, from, info.price);

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
