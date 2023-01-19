pragma solidity ^0.8.0;

contract DeflationaryToken {
    address owner;
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        owner = msg.sender;
        balanceOf[owner] = 1000000;
        totalSupply = 1000000;
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(value > 0);

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    function burn(uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(value > 0);

        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }
}
