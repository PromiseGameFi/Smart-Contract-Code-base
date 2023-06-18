//Professional but with converting to bnb

// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyToken is IBEP20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public excludedFromFees;
    
    address public dexWallet;
    address public developmentWallet;
    address public marketingWallet;
    address private _owner;

    uint256 public feePercentage = 7;

   

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function.");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        _owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _initialSupply * 10**uint256(decimals);
        _balances[msg.sender] = _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(amount <= _allowances[sender][msg.sender], "Insufficient allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function setDevelopmentWallet(address _developmentWallet) external onlyOwner {
        require(_developmentWallet != address(0), "Invalid development wallet address.");
        developmentWallet = _developmentWallet;
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "Invalid marketing wallet address.");
        marketingWallet = _marketingWallet;
    }

    function setDexWallet(address _dexWallet) external onlyOwner {
        require(_dexWallet != address(0), "Invalid DEX wallet address.");
        dexWallet = _dexWallet;
    }

    function excludeFromFees(address _address) external onlyOwner {
        excludedFromFees[_address] = true;
    }

    function includeInFees(address _address) external onlyOwner {
        excludedFromFees[_address] = false;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Invalid sender address.");
        require(recipient != address(0), "Invalid recipient address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(_balances[sender] >= amount, "Insufficient balance.");

        bool isFeeExempt = excludedFromFees[sender] || excludedFromFees[recipient];
        uint256 feeAmount = 0;

        if (!isFeeExempt && dexWallet != address(0) && (sender == dexWallet || recipient == dexWallet)) {
            feeAmount = (amount * feePercentage) / 100;
            _balances[developmentWallet] += feeAmount / 2;
            _balances[marketingWallet] += feeAmount / 2;
        }

        _balances[sender] -= amount;
        _balances[recipient] += amount - feeAmount;

        emit Transfer(sender, recipient, amount);
        if (feeAmount > 0) {
            emit Transfer(sender, developmentWallet, feeAmount / 2);
            emit Transfer(sender, marketingWallet, feeAmount / 2);
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Invalid owner address.");
        require(spender != address(0), "Invalid spender address.");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
