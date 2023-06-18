// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public excludedFromFees;
    address public DexWallet;
    address public developmentWallet;
    address public marketingWallet;

    uint256 public feePercentage = 7;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == DexWallet, "Only the DexWallet can call this function.");
        _;
    }

    function setDevelopmentWallet(address _developmentWallet) external onlyOwner {
        developmentWallet = _developmentWallet;
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        marketingWallet = _marketingWallet;
    }

    function setDexWallet(address _DexWallet) external onlyOwner {
        DexWallet = _DexWallet;
    }

    function excludeFromFees(address _address) external onlyOwner {
        excludedFromFees[_address] = true;
    }

    function includeInFees(address _address) external onlyOwner {
        excludedFromFees[_address] = false;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Invalid recipient address.");
        require(_value <= balanceOf[msg.sender], "Insufficient balance.");

        if (DexWallet == msg.sender || DexWallet == _to) {
            if (excludedFromFees[msg.sender] || excludedFromFees[_to]) {
                // Normal transfer without fee
                balanceOf[msg.sender] -= _value;
                balanceOf[_to] += _value;
            } else {
                // Deduct fee and distribute
                uint256 feeAmount = (_value * feePercentage) / 100;
                uint256 transferAmount = _value - feeAmount;

                require(
                    transferAmount > 0 && balanceOf[developmentWallet] + balanceOf[marketingWallet] + transferAmount == _value,
                    "Fee distribution error."
                );

                balanceOf[msg.sender] -= _value;
                balanceOf[_to] += transferAmount;
                balanceOf[developmentWallet] += feeAmount / 2;
            balanceOf[marketingWallet] += feeAmount / 2;

                emit Transfer(msg.sender, _to, transferAmount);
                emit Transfer(msg.sender, developmentWallet, feeAmount / 2);
                emit Transfer(msg.sender, marketingWallet, feeAmount / 2);
            }
        } else {
            // Normal transfer without fees
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

}
