// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "hardhat/console.sol";



contract SnowmenGame is ERC1155Supply, Ownable {

    using Strings for uint256;

    using Counters for Counters.Counter;

    mapping(uint256 => string) public metadataHash;
    mapping(address => bool) private _authorized;

    modifier onlyAuthorized() {
        require(
            _authorized[msg.sender] || owner() == msg.sender,
            "not authorized"
        );
        _;
    }

    Counters.Counter public folderId;


    function mint(address receiver, uint256 tokenId, uint256 quantity) external onlyAuthorized {
         _mint(receiver, tokenId, quantity, "");
    }


    constructor() ERC1155("") {
        folderId.increment();
    }


    function confirmUpload(string calldata cidHash) external onlyOwner {
        metadataHash[folderId.current()] = cidHash;
        folderId.increment();
    }


    function getIds(uint256 numOfMeta) external view returns (uint256[] memory) {

        uint256[] memory ids = new uint256[](numOfMeta);


        console.log("current >>", folderId.current());
        for (uint256 i = 0; i < ids.length; ++i) {

            uint256 tokenId = (folderId.current() << 128) | i;

            ids[i] = tokenId;

        }

        return ids;

    }


    function tokenToFolderId(uint256 tokenId) public pure returns (uint256) {

       return tokenId >> 128;

    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    "ipfs://",
                    metadataHash[tokenToFolderId(tokenId)],
                    "/",
                    Strings.toString(tokenId),
                    ".json"
                )
            )
        );
    }

    function addAuthorized(address authorized) external onlyOwner {
        _authorized[authorized] = true;
    }

    function removeAuthorized(address authorized) external onlyOwner {
        _authorized[authorized] = false;
    }
}
// 340282366920938463463374607431768211456,340282366920938463463374607431768211457,340282366920938463463374607431768211458