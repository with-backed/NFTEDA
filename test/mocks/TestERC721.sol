// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract TestERC721 is ERC721("Test", "TEST") {
    function tokenURI(uint256 id) public view override returns (string memory) {}

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }
}
