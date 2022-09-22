// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {ExponentialPriceDecayNFTAuction} from "src/ExponentialPriceDecayNFTAuction.sol";
import {SimplePurchaseNFT} from "src/periphery/SimplePurchaseNFT.sol";
import {TestERC721} from "test/mocks/TestERC721.sol";
import {TestERC20} from "test/mocks/TestERC20.sol";

contract SimplePurchaseNFTTest is Test {
    SimplePurchaseNFT simplePurchase = new SimplePurchaseNFT();
    TestERC721 nft = new TestERC721();

    function testDoesNotAcceptNFTS() public {
        nft.mint(address(this), 1);
        vm.expectRevert(SimplePurchaseNFT.WrongFrom.selector);
        nft.safeTransferFrom(address(this), address(simplePurchase), 1);
    }
}
