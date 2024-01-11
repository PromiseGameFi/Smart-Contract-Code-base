// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CustomNFT is ERC721, Ownable {
    constructor() ERC721("CustomNFT", "CNFT") {}

    // Mapping to store ERC-20 balances for each token ID
    mapping(uint256 => mapping(address => uint256)) private erc20Balances;

    // Event to log when ERC-20 tokens are received
    event ERC20Received(uint256 tokenId, address from, uint256 amount);

    // Event to log when ERC-20 tokens are sent
    event ERC20Sent(uint256 tokenId, address to, uint256 amount);

    // Event to log when Ether is received
    event EtherReceived(uint256 tokenId, address from, uint256 amount);

    // Event to log when Ether is sent
    event EtherSent(uint256 tokenId, address to, uint256 amount);

    // Function to mint a new token and create a unique address for it
    function mint() external onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
    }

    // Function to check ERC-20 balance for a specific token ID
    function getERC20Balance(uint256 tokenId, address erc20Token) external view returns (uint256) {
        return erc20Balances[tokenId][erc20Token];
    }

    // Function to receive ERC-20 tokens
    function receiveERC20(uint256 tokenId, address erc20Token, uint256 amount) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(amount > 0, "Invalid amount");

        // Transfer ERC-20 tokens to the contract
        IERC20(erc20Token).transferFrom(msg.sender, address(this), amount);

        // Update the ERC-20 balance for the token ID
        erc20Balances[tokenId][erc20Token] += amount;

        // Emit an event
        emit ERC20Received(tokenId, nftOwner(tokenId), amount);
    }

    // Function to send ERC-20 tokens to a specific address
    function sendERC20(uint256 tokenId, address erc20Token, uint256 amount) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(amount > 0, "Invalid amount");
        require(erc20Balances[tokenId][erc20Token] >= amount, "Insufficient ERC-20 balance");

        // Transfer ERC-20 tokens to the owner's address
        IERC20(erc20Token).transfer(nftOwner(tokenId), amount);

        // Update the ERC-20 balance for the token ID
        erc20Balances[tokenId][erc20Token] -= amount;

        // Emit an event
        emit ERC20Sent(tokenId, nftOwner(tokenId), amount);
    }

    // Function to receive Ether
    receive() external payable {
        emit EtherReceived(0, msg.sender, msg.value);
    }

    // Function to send Ether to a specific address
    function sendEther(uint256 tokenId, uint256 amount) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(amount > 0 && amount <= address(this).balance, "Invalid amount");

        // Transfer Ether to the owner's address
        payable(nftOwner(tokenId)).transfer(amount);

        // Emit an event
        emit EtherSent(tokenId, nftOwner(tokenId), amount);
    }

    // Internal function to get the owner's address for a given token ID
    function nftOwner(uint256 tokenId) internal view returns (address) {
        return ownerOf(tokenId);
    }
}
