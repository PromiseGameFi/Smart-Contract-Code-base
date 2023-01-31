// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BionicOwlsEns is ERC721, ERC721Burnable, Ownable {

    mapping(address => string) public addresses;
    mapping(string => address) public names;
    mapping(string => address) public creators;
    mapping(address => bool) public nameCreationStatus;
    mapping(uint256 => string) public IdToName;
    mapping(string => uint256) public NameToId;
   

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") {}
  
    function createName(string memory name) public {
      require(names[name] == address(0), "Name already exists");
      require(!nameCreationStatus[msg.sender], "You have already created a name");

      creators[name] = msg.sender;
      names[name] = msg.sender;
      addresses[msg.sender] = name;
      nameCreationStatus[msg.sender] = true;
      uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        IdToName[tokenId] = name;
        NameToId[name] = tokenId;
    }

  function transferName(string memory name, address newOwner) public {
    require(names[name] == msg.sender, "You don't own this name");
    //Requirement to check if the receiver already has
    require(!nameCreationStatus[newOwner], "New Owner Already has a name");
    
    names[name] = newOwner;
    addresses[newOwner] = name;
    addresses[msg.sender] = "";
    nameCreationStatus[msg.sender] = false;
    safeTransferFrom(msg.sender, newOwner, NameToId[name]);
    nameCreationStatus[newOwner] = true;
  }

  function deleteName(string memory name) public {
    require(names[name] == msg.sender, "You don't own this name");
    addresses[msg.sender] = "";
    delete names[name];
    delete creators[name];
    nameCreationStatus[msg.sender] = false;
    //Make Sure you set name to id to be zero also
    IdToName[NameToId[name]] = "";
    NameToId[name] = 0;
    burn(NameToId[name]);
  }

  function getCreator(string memory name) public view returns (address) {
    return creators[name];
  }

  function getOwner(string memory name) public view returns (address) {
    return names[name];
  }
}
