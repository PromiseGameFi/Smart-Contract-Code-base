// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NameService is ERC721 {
    uint256 public maxSupply;
    uint256 public totalSupply;
    address payable public owner;
    uint _id = 0;

    // mapping from name to address
    mapping(string => address payable) public nameToAddress;
    mapping(address => string) public addressToName;
    mapping(uint256 => string) public tokenIdToName;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {

    }

    // function to create a name
    function createName(string memory _name) public payable {
        // check if the name has already been taken
        require(nameToAddress[_name] == address(0), "Name has already been taken");
        // assign the name to the address
        nameToAddress[_name] = payable(msg.sender);
        // assign the name to the address in the addressToName mapping
        addressToName[payable(msg.sender)] = _name;
        // assign the token ID to the name
        tokenIdToName[_id] = _name;
        totalSupply++;
        _id++;
        _safeMint(msg.sender, _id);
    }

    // function to send ether using a name
    function sendEther(string memory _name, uint _value) public payable {
        // get the address associated with the name
        address payable recipient = nameToAddress[_name];
        // send the ether to the address
        recipient.transfer(_value);
    }

    function getName() public view returns (string memory) {
        return addressToName[msg.sender];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        super.transferFrom(from, to, tokenId);
        tokenIdToName[tokenId] = addressToName[to];
    }
}
