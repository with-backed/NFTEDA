// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SimpleNFTEDA} from "src/extensions/SimpleNFTEDA.sol";
import {INFTEDAPublic} from "./INFTEDAPublic.sol";

contract TestSimpleNFTEDA is INFTEDAPublic, SimpleNFTEDA {
    function startAuction(Auction memory auction) external returns (uint256 id) {
        return _startAuction(auction);
    }

    function purchaseNFT(Auction memory auction, uint256 maxPrice) external {
        _purchaseNFT(auction, maxPrice);
    }
}
