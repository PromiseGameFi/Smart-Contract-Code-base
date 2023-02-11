// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BetCode {
    uint256 public RandomWin;

    mapping(address => uint256) public  GetPlayerBet;
    mapping(address => bool) public IsCorrect;
    //Function to make a bet 
    function MakeABet(uint256 betNumber, uint256 BetPrice ) public payable {
        RandomWin = RandonPicker();
        //Convert PaidValue to Eth
        uint256 PaidValue = BetPrice * 2 * 1 ether;
        //Convert BetPrice to Eth
        uint256 EthBetPrice = BetPrice * 1 ether;
        if(RandonPicker() == betNumber)
        {
            IsCorrect[msg.sender] = true;
            //Send Winnings to owner
            payable(msg.sender).transfer(PaidValue);
        }else
        {
            IsCorrect[msg.sender] = false;
            //Send Money back to Owner
            payable(msg.sender).transfer(EthBetPrice);
        }
    }
    //Function to Get Random Number
    function RandonPicker() public view returns (uint) {
       return uint(keccak256(abi.encodePacked(block.timestamp))) % 2 + 1;
    }

    receive() external payable {}

}