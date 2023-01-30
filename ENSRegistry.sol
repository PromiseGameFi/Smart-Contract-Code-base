// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ENSName {
  mapping(string => address) public names;
  mapping(string => address) public creators;

  function createName(string calldata name) public {
    require(names[name] == address(0), "Name already exists");
    creators[name] = msg.sender;
    names[name] = msg.sender;
  }

  function transferName(string calldata name, address newOwner) public {
    require(names[name] == msg.sender, "You don't own this name");
    names[name] = newOwner;
  }

  function getCreator(string calldata name) public view returns (address) {
    return creators[name];
  }

  function getOwner(string calldata name) public view returns (address) {
    return names[name];
  }
}
