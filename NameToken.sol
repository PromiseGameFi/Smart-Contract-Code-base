pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract NameToken is ERC721Full {
  mapping(uint256 => string) public names;

  constructor() ERC721Full("NameToken", "NT") public {
  }

  function setName(uint256 _tokenId, string memory _name) public {
    require(names[_tokenId] == "", "Name already set");
    names[_tokenId] = _name;
  }

  function getName(uint256 _tokenId) public view returns (string memory) {
    return names[_tokenId];
  }
}
