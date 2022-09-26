// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFTEDA} from "src/NFTEDA.sol";

contract SimpleNFTEDA is NFTEDA {
    mapping(uint256 => uint256) internal _auctionStartTime;

    function auctionStartTime(uint256 id) public view override returns (uint256) {
        return _auctionStartTime[id];
    }

    function _setAuctionStartTime(uint256 id) internal virtual override {
        _auctionStartTime[id] = block.timestamp;
    }

    function _clearAuctionState(uint256 id) internal virtual override {
        delete _auctionStartTime[id];
    }
}
