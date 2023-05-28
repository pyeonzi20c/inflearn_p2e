// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract SnowmenGame is ERC1155Supply, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter public folderId;

    constructor() ERC1155("") {
        folderId.increment();
    }
}