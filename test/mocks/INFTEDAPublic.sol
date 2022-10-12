// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {INFTEDA} from "src/interfaces/INFTEDA.sol";

interface INFTEDAPublic is INFTEDA {
    function startAuction(INFTEDA.Auction memory auction) external returns (uint256 id);

    function purchaseNFT(INFTEDA.Auction memory auction, uint256 maxPrice) external;
}
