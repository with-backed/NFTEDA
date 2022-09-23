// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {NFTEDA} from "src/NFTEDA.sol";
import {SimplePurchaseNFT} from "src/periphery/SimplePurchaseNFT.sol";

contract PayTooLittlePurchasePeriphery is SimplePurchaseNFT {
    function onERC721Received(address from, address, uint256, bytes calldata data) external override returns (bytes4) {
        (NFTEDA.CallbackInfo memory info) =
            abi.decode(data, (NFTEDA.CallbackInfo));
        (address payer, ERC20 asset) = abi.decode(info.passedData, (address, ERC20));

        asset.transferFrom(payer, from, info.price - 1);

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
