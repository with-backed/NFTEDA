// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFTEDAStarterIncentive} from "src/extensions/NFTEDAStarterIncentive.sol";
import {INFTEDAPublic} from "./INFTEDAPublic.sol";

contract TestNFTEDAStarterIncentive is INFTEDAPublic, NFTEDAStarterIncentive {
    constructor(uint256 discount) NFTEDAStarterIncentive(discount) {}

    function startAuction(Auction memory auction) external returns (uint256 id) {
        return _startAuction(auction);
    }

    function purchaseNFT(Auction memory auction, uint256 maxPrice, address sendTo) external {
        _purchaseNFT(auction, maxPrice, sendTo);
    }
}
