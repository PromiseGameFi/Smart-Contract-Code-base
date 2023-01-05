//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CatBreeder {
  // Cat struct
    struct Cat {
      string name;
      uint price;
      string breed;
      bool isMale;
    }

    // Mapping from Cat ID to Cat struct
    mapping(uint => Cat) public Cats;
    // Create a mapping to store the cats
    mapping(string => Cat) public catName;


    // Array of all Cat IDs
    uint[] public CatIds;

    // Counter for Cat ID
    uint public CatIdCounter = 0;

    function createCats(string[] memory nameOfmale, string[] memory nameOfFemale) public {
      // Create 10 Cats with 5 male and 5 female Cats
      for (uint i = 0; i < 5; i++) {
        CatIdCounter++;
        Cats[CatIdCounter] = Cat(nameOfmale[i], 1 ether, "Mixed", true);
        CatIds.push(CatIdCounter);
      }
      for (uint i = 0; i < 5; i++) {
        CatIdCounter++;
        Cats[CatIdCounter] = Cat(nameOfFemale[i], 1 ether, "Mixed", false);
        CatIds.push(CatIdCounter);
      }
    }
    // Buy a Cat
    function buyCat(uint _CatId, uint _price) public payable {
      // Check that the Cat is for sale
      require(Cats[_CatId].price > 0, "Cat is not for sale");

      // Check that the player has enough balance
      require(msg.value >= _price, "Insufficient balance");
      Cats[_CatId].price = msg.value;
      address payable buyerOfKit = payable(msg.sender);
      // Transfer the Cat's price to the contract owner
      buyerOfKit.transfer(_price);
      // Set the Cat's price to 0 to indicate that it has been sold
      Cats[_CatId].price = 0;
    }

    // Breed two Cats to create a new Cat
    function breedCats(uint _CatId1, uint _CatId2, string memory _name, uint _price) public {
      // Check that both Cats are owned by the player
      require(Cats[_CatId1].price == 0, "Cat is not owned by player");
      require(Cats[_CatId2].price == 0, "Cat is not owned by player");

      // Check that one Cat is male and the other is female
      require(Cats[_CatId1].isMale != Cats[_CatId2].isMale, "Cats must be male and female");

      // Generate a random number between 0 and 1 to determine the gender of the new Cat
      //bool randomNumber = random();
      bool isMale = random();

      // Create a new Cat and add it to the mapping
      CatIdCounter++;
      Cats[CatIdCounter] = Cat(_name, _price, "Mixed", isMale);

      // Add the new Cat's ID to the array of all Cat IDs
      CatIds.push(CatIdCounter);
    }

    function MultipleCatsBreeding(uint[] memory _CatIds, string memory _name, uint _price) public {
    //Players Can breed Multiple  Cats
    // Check that all of the Cats are owned by the player
    for (uint i = 0; i < _CatIds.length; i++) {
      require(Cats[_CatIds[i]].price == 0, "Cat is not owned by player");
    }
    // Create New Breeds
    // Generate a random number between 0 and 1 to determine the gender of the new Cat
    bool isMale = random();
    // Create a new Cat and add it to the mapping
    CatIdCounter++;
    Cats[CatIdCounter] = Cat(_name, _price, "Mixed", isMale);
    // Add the new Cat's ID to the array of all Cat IDs
    CatIds.push(CatIdCounter);
    }


    // Sell a Cat
    function sellCat(uint _CatId, uint _price) public {
      // Check that the Cat is owned by the player
      require(Cats[_CatId].price == 0, "Cat is not owned by player");

      // Set the Cat's price to the sale price
      Cats[_CatId].price = _price;
    }

    // Generate a random number between 0 and 1
    function random() private view returns (bool) {
      return (uint256(keccak256(abi.encodePacked(block.timestamp, this))) & 1) == 1;
    }

  
}
