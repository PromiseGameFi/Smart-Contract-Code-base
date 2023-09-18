// SPDX-License-Identifier: GPL-3.0

//ZK Proof for game Assets

pragma solidity ^0.8.0;

contract GameContract {
    struct User {
        uint256 userId;
        string username;
        mapping(uint256 => uint256) assets; // Mapping from assetId to asset quantity
        mapping(uint256 => bool) collectibles; // Mapping from collectibleId to ownership status
    }

    mapping(address => User) public users;
    mapping(uint256 => string) public assets; // Mapping from assetId to asset name
    mapping(uint256 => string) public collectibles; // Mapping from collectibleId to collectible name

    uint256 public nextUserId;
    uint256 public nextAssetId;
    uint256 public nextCollectibleId;

    event UserCreated(address indexed userAddress, uint256 userId, string username);
    event AssetCreated(uint256 assetId, string assetName);
    event CollectibleCreated(uint256 collectibleId, string collectibleName);
    event AssetAcquired(address indexed userAddress, uint256 assetId, uint256 quantity);
    event CollectibleAcquired(address indexed userAddress, uint256 collectibleId);

    modifier onlyUser() {
        require(users[msg.sender].userId != 0, "User does not exist");
        _;
    }

    // Function to verify zero-knowledge proof for ownership
    
    function verifyOwnershipZKP(uint256 assetId, uint256[] memory proof) internal pure returns (bool) {
        // Placeholder logic to demonstrate a ZKP verification (not secure, for demonstration purposes only)

        // Check that the proof array has the expected length
        require(proof.length == 2, "Invalid proof length");

        // Check the validity of the proof based on the assetId
        if (assetId == 1) {
            return proof[0] == 2 && proof[1] == 3;  // Placeholder values for demonstration
        } else if (assetId == 2) {
            return proof[0] == 4 && proof[1] == 5;  // Placeholder values for demonstration
        }
    
        return false;  // Default case, invalid assetId
    }


    function createUser(string memory _username) public {
         require(users[msg.sender].userId == 0, "User already exists");

         nextUserId++;
        users[msg.sender].userId = nextUserId;
        users[msg.sender].username = _username;

        emit UserCreated(msg.sender, nextUserId, _username);
    }


    function createAsset(string memory _assetName) public {
        nextAssetId++;
        assets[nextAssetId] = _assetName;

        emit AssetCreated(nextAssetId, _assetName);
    }

    function createCollectible(string memory _collectibleName) public {
        nextCollectibleId++;
        collectibles[nextCollectibleId] = _collectibleName;

        emit CollectibleCreated(nextCollectibleId, _collectibleName);
    }

    function acquireAsset(uint256 _assetId, uint256 _quantity, uint256[] memory proof) public onlyUser {
        // Check if the asset exists (non-empty string)
        require(bytes(assets[_assetId]).length != 0, "Asset does not exist");
        require(_quantity > 0, "Quantity must be greater than 0");

        // Verify ownership using ZKP
        bool isProofValid = verifyOwnershipZKP(_assetId, proof);
        require(isProofValid, "Invalid ownership proof");

        users[msg.sender].assets[_assetId] += _quantity;

        emit AssetAcquired(msg.sender, _assetId, _quantity);
    }

    function acquireCollectible(uint256 _collectibleId, uint256[] memory proof) public onlyUser {
        // Check if the collectible exists (non-empty string)
        require(bytes(collectibles[_collectibleId]).length != 0, "Collectible does not exist");

        // Verify ownership using ZKP
        bool isProofValid = verifyOwnershipZKP(_collectibleId, proof);
        require(isProofValid, "Invalid ownership proof");

       users[msg.sender].collectibles[_collectibleId] = true;

        emit CollectibleAcquired(msg.sender, _collectibleId);
    }

}
