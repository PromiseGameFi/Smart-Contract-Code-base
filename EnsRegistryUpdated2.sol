// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BionicOwlsEns {
  mapping(address => string) public addresses;
  mapping(string => address) public names;
  mapping(string => address) public creators;
  mapping(address => bool) public nameCreationStatus;
  
  function createName(string memory name) public {
    require(names[name] == address(0), "Name already exists");
    require(!nameCreationStatus[msg.sender], "You have already created a name");
    
    creators[name] = msg.sender;
    names[name] = msg.sender;
    addresses[msg.sender] = name;
    nameCreationStatus[msg.sender] = true;
  }

  function transferName(string memory name, address newOwner) public {
    require(names[name] == msg.sender, "You don't own this name");
    names[name] = newOwner;
    addresses[newOwner] = name;
    addresses[msg.sender] = "";
    nameCreationStatus[msg.sender] = false;
    nameCreationStatus[newOwner] = true;
  }

  function deleteName(string memory name) public {
    require(names[name] == msg.sender, "You don't own this name");
    addresses[msg.sender] = "";
    delete names[name];
    delete creators[name];
    nameCreationStatus[msg.sender] = false;
  }

  function getCreator(string memory name) public view returns (address) {
    return creators[name];
  }

  function getOwner(string memory name) public view returns (address) {
    return names[name];
  }
}

