//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}
contract Staking {
    //@notice: This Staking contract works for Multiple users for Multiple staking instances. Working of this contract
    // goes like when user stakes there will be staking ID given to the user represting that particular stake action
    // when user withdraws then user should provide their staking IDs to be withdrawn.
    // Libraries like safemath, iterable mapping are not used here intentionally because this is not the code for production
    
    // Also This contract is only for staking , i assume that you've already create the DEFI token and will transferring 
    // the token amount ( reserved for staking rewards) to this contract. 
    struct Data {
        uint256 Amount;
        uint256 Blocknum;
    }
    address public immutable Token;
    mapping(address => mapping(uint256 => Data)) public userRewards;
    uint256 public stakeID;

    constructor(address token) {
        Token = token;
    }

    function stake(uint256 amount) external returns (uint256) {
        TransferHelper.safeTransferFrom(
            Token,
            msg.sender,
            address(this),
            amount
        );
        stakeID++;
        userRewards[msg.sender][stakeID] = Data(amount, block.number);
        return stakeID;
    }

    function Unstake(uint256[] calldata stakeIDs) external {
        uint256 amount = calculate(stakeIDs); // check effects interaction pattern implemented
        TransferHelper.safeTransfer(Token, msg.sender, amount);
    }

    function calculate(uint256[] memory IDs) internal returns (uint256) {
        uint256 Rewardsamount;
        uint256 totalAmt;
        for (uint256 i = 0; i < IDs.length; i++) { 
            Data memory data = userRewards[msg.sender][IDs[i]]; // saving gas
            uint256 blockvalue = block.number - data.Blocknum;
            Rewardsamount += (data.Amount * blockvalue);
            totalAmt += data.Amount;
            delete userRewards[msg.sender][IDs[i]];
        }
        return (Rewardsamount + totalAmt);
    }

    function viewRewards(uint[] memory IDs) external view returns (uint256) {
        uint256 Rewardsamount;
        for (uint256 i = 0; i < IDs.length; i++) {
            Data memory data = userRewards[msg.sender][IDs[i]];
            uint256 blockvalue = block.number - data.Blocknum;
            Rewardsamount += (data.Amount * blockvalue);
        }
        return (Rewardsamount);
    }
}
