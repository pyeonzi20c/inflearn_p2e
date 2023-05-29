// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";


contract SnowmenSales is Ownable, ERC1155Holder {

    using SafeERC20 for IERC20;

    IERC20 public snowmenToken;

    IERC1155 public snowmenGame;

    mapping(uint256 => uint256) public tokenPrice;

    uint256 private constant TICKET_PRICE = 0.01 ether;
    uint256 private constant TICKET_QUANTITY = 1;
    uint256 private constant TICKET_ID = 340282366920938463463374607431768211456;

    event SetPrice (
        uint256 tokenId,
        uint256 price,
        uint256 timestamp
    );

    event onERC1155ReceivedExecuted (
        address operator,
        address from,
        uint256 id,
        uint256 value
    );

    event BuyItem (
        address indexed buyer,
        uint256 tokenId,
        uint256 amount,
        uint8 quantity,
        uint256 timestamp
    );

    event BuyTicker(
        address indexed buyer,
        uint256 timestamp
    );

    event Withdraw(
        address owner,
        uint256 amount
    );

    constructor(address snowmenErc1155, address snowmenErc20) {

        snowmenGame = IERC1155(snowmenErc1155);

        snowmenToken = IERC20(snowmenErc20);

    }
    
    function onERC1155Received(
        address operator, // transfer 를 실행하는 계정
        address from,
        uint256 id,
        uint256 value,
        bytes memory
    ) public override returns (bytes4) {
        require(msg.sender == address(snowmenGame), "incorrect sender");
        require(value != 0, "quantity is zero");
        emit onERC1155ReceivedExecuted(operator, from, id, value);
        return this.onERC1155Received.selector;
    }

    function setPrice(uint256 tokenId, uint256 price) external onlyOwner {
        require(tokenId != 0, "tokenId is zero");
        require(price != 0, "price is zero");
        tokenPrice[tokenId] = price;
        emit SetPrice(
            tokenId,
            price,
            block.timestamp
        );

        console.log("address this", address(this));
        console.log("address owner", owner());
    }

    function buyItem(
        uint256 tokenId,
        uint256 amount,
        uint8 quantity
    ) external {
        address buyer = msg.sender;
        require(tokenPrice[tokenId] != 0, "price not set yet");
        require(amount >= tokenPrice[tokenId] * quantity, "amount not enough");
        require(snowmenGame.balanceOf(address(this), tokenId) >= quantity);
        require(snowmenToken.balanceOf(buyer) >= amount, "insufficient token");
        require(snowmenToken.allowance(buyer, address(this)) >= amount, "insufficient token approval");

        snowmenToken.safeTransferFrom(buyer, owner(), amount);
        snowmenGame.safeTransferFrom(address(this), buyer, tokenId, quantity, "");

        emit BuyItem(buyer, tokenId, amount, quantity, block.timestamp);
    }

    function buyTicket() external payable {
        require(msg.value >= TICKET_PRICE, "price not enough");

        // gas 비용을 아끼기위한 raw level call
        // (bool success, bytes memory returnData) = address(snowmenGame).call(
        (bool success,) = address(snowmenGame).call(
            abi.encodeWithSignature("mint(address,uint256,uint256)",
                msg.sender,
                TICKET_ID,
                TICKET_QUANTITY
            )
        );
        require(success, "mint failed.");

        emit BuyTicker(
            msg.sender,
            block.timestamp
        );
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner() {
        uint256 amount = getBalance();
        require(amount != 0, "insufficent balance");
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "unable to withdraw matic");
        emit Withdraw(
            msg.sender,
            amount
        );
    }
}