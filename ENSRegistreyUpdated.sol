// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract NameRegistry {
  mapping(address => string) public addresses;
  mapping(string => address) public names;
  mapping(string => address) public creators;
  mapping(address => bool) public hasName;

  function createName(string memory name) public {
    require(names[name] == address(0), "Name already exists");
    require(!hasName[msg.sender], "Address already has a name");
    creators[name] = msg.sender;
    names[name] = msg.sender;
    addresses[msg.sender] = name;
    hasName[msg.sender] = true;
  }

  function transferName(string memory name, address newOwner) public {
    require(names[name] == msg.sender, "You don't own this name");
    names[name] = newOwner;
    addresses[newOwner] = name;
    hasName[newOwner] = true;
    addresses[msg.sender] = "";
    hasName[msg.sender] = false;
  }

  function deleteName(string memory name) public {
    require(names[name] == msg.sender, "You don't own this name");
    addresses[msg.sender] = "";
    hasName[msg.sender] = false;
    delete names[name];
    delete creators[name];
  }

  function getCreator(string memory name) public view returns (address) {
    return creators[name];
  }

  function getOwner(string memory name) public view returns (address) {
    return names[name];
  }
}

