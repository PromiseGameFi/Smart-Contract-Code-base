// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


interface IERC20
{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ICO
{
    event ExtractedToken(address indexed from, address indexed to, uint256 value);
    event ExtractedEther(address indexed from, address indexed to, uint256 value);
    event ClaimedTokens(address indexed to, uint256 value);

    address private _owner;
    bool private _isICOActive;

    IERC20 private _token;
    uint8 private _decimals;
    uint256 private _tokenRate;
    uint256 private _fundingGoal;
    uint256 private _etherRaised;

    mapping(address => bool) private _isInvestor;
    mapping(address => uint256) private _invested;
    bool private _isClaimable;

    constructor()
    {
        _owner = msg.sender;
        _isICOActive = false;
        _isClaimable = false;
    }

    modifier onlyOwner
    {
        require(msg.sender == _owner, "Permission Denied!");
        _;
    }

    function setICO(address tokenAddress, uint8 decimals, uint256 tokenRate, uint256 fundingGoal) onlyOwner external
    {
        _token = IERC20(tokenAddress);

        _decimals = decimals;
        _tokenRate = tokenRate;
        _fundingGoal = fundingGoal;
    }

    function enableICO() onlyOwner external
    {
        _isICOActive = true;
    }

    function disbaleICO() onlyOwner external
    {
        _isICOActive = false;
    }

    function isICOActive() external view returns (bool)
    {
        return _isICOActive;
    }
    
    function enableClaim() onlyOwner external
    {
        _isClaimable = true;
    }

    function disbaleClaim() onlyOwner external
    {
        _isClaimable = false;
    }

    function isClaimable() external view returns (bool)
    {
        return _isClaimable;
    }

    function claimToken() external returns (bool)
    {
        require(_isClaimable, "Can't claim, tokens are still not claimable!");
        require(_isInvestor[msg.sender], "Can't claim, you're not an Investor!");
        require(_invested[msg.sender] > 0, "Can't claim, you have no tokens to claim!");
        _token.transfer(msg.sender, _invested[msg.sender]);
        emit ClaimedTokens(msg.sender, _invested[msg.sender]);
        _invested[msg.sender] = 0;
        _isInvestor[msg.sender] = false;
        return true;
    }

    function extractTokens(uint256 amount) onlyOwner external returns (bool)
    {
        _token.transfer(_owner, amount * (10 **  _decimals));
        emit ExtractedToken(address(this), _owner, amount);
        return true;
    }

    function extractAllTokens() onlyOwner external returns (bool)
    {
        _token.transfer(_owner, _token.balanceOf(address(this)));
        emit ExtractedToken(address(this), _owner, _token.balanceOf(address(this)));
        return true;
    }

    function extractEther(uint256 amount) onlyOwner external returns (bool)
    {
        require(address(this).balance >= 0, "Zero Balance!");
        payable(msg.sender).transfer(amount * 1 ether);
        emit ExtractedEther(address(this), _owner, amount);
        return true;
    }

    function extractAllEther() onlyOwner external returns (bool)
    {
        require(address(this).balance >= 0, "Zero Balance!");
        payable(msg.sender).transfer(address(this).balance);
        emit ExtractedEther(address(this), _owner, address(this).balance);
        return true;
    }
    
    receive() external payable
    {
        buy();
    }

    function buy() public payable returns (bool)
    {
        require(_isICOActive, "ICO is not active!");
        //require((_fundingGoal * 1 ether - _etherRaised) != 0, "Reached Fundraising Goal!");
        //require(msg.value <= (_fundingGoal * 1 ether - _etherRaised), "Try smaller amount!");
        _etherRaised += msg.value;
        _isInvestor[msg.sender] = true;
        _invested[msg.sender] += msg.value * _tokenRate;
        return true;
    }
}
