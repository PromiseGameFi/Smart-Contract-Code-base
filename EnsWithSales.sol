// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Ens {
  mapping(address => string) public addresses;
  mapping(string => address) public names;
  mapping(string => address) public creators;
  mapping(address => bool) public nameCreationStatus;
  mapping(string => uint256) public namePrices;
  string[] public allNamesForSale;
  
  
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

  

    function setNamePrice(string memory name, uint256 price) public {
        require(names[name] == msg.sender, "You don't own this name");
        namePrices[name] = price;
        allNamesForSale.push(name);
    }

    function DeListName(string memory name) public {
        require(names[name] == msg.sender, "You don't own this name");
        namePrices[name] = 0;
        deleteNameFromAllNames(name);
    }

    function purchaseName(string memory name) public payable {
        require(names[name] != address(0), "Name does not exist");
        require(namePrices[name] != 0, "Name is not for sale");
        require(msg.value >= namePrices[name], "Insufficient payment");

        address owner = names[name];
        names[name] = msg.sender;
        addresses[owner] = "";
        addresses[msg.sender] = name;
        nameCreationStatus[owner] = false;
        nameCreationStatus[msg.sender] = true;
        namePrices[name] = 0;

        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Transfer failed.");
        deleteNameFromAllNames(name);
    }

    function getAllNames() public view returns (string[] memory) {
        return allNamesForSale;
    }

    function deleteNameFromAllNames(string memory name) internal {
        for (uint i = 0; i < allNamesForSale.length; i++) {
          if (keccak256(bytes(allNamesForSale[i])) == keccak256(bytes(name))) {
            allNamesForSale[i] = allNamesForSale[allNamesForSale.length - 1];
            allNamesForSale.pop();
            break;
          }
        }
    }


}
