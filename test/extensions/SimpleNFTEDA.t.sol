// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "src/extensions/SimpleNFTEDA.sol";
import {NFTEDATest} from 'test/NFTEDA.t.sol';
import {TestSimpleNFTEDA} from "test/mocks/TestSimpleNFTEDA.sol";

contract SimpleNFTEDATest is NFTEDATest {
    function _createAuctionContract() internal override {
        auctionContract = new TestSimpleNFTEDA();
    }
}
