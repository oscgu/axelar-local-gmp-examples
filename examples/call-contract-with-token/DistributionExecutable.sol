//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';

contract DistributionExecutable is AxelarExecutable {
    IAxelarGasService public immutable gasReceiver;

    /**
     * @notice Internal representation of a receipt
     */
    struct Receipt {
        address sender;
        address[] receivers;
        address token;
        uint256 value;
        string message;
    }

    /**
     * @notice Stores all receipts
     */
    Receipt[] Receipts;

    /**
     * @notice Returns all receipts
     */
    function getReceipts() public view returns (Receipt[] memory) {
        return Receipts;
    }

    /**
     * @notice Returns a single receipt
     * @param index Index of the receipt
     */
    function getReceipt(uint256 index) public view returns (Receipt memory) {
        return Receipts[index];
    }


    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
    }

    function sendToMany(
        string memory destinationChain,
        string memory destinationAddress,
        address[] calldata destinationAddresses,
        string memory symbol,
        string calldata message,
        uint256 amount
    ) external payable {
        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);

        bytes memory payload = abi.encode(destinationAddresses, msg.sender, message);
        if (msg.value > 0) {
            gasReceiver.payNativeGasForContractCallWithToken{ value: msg.value }(
                address(this),
                destinationChain,
                destinationAddress,
                payload,
                symbol,
                amount,
                msg.sender
            );
        }

        gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        (address[] memory recipients, address sender, string memory message) = abi.decode(payload, (address[], address, string));
        address tokenAddress = gateway.tokenAddresses(tokenSymbol);
        Receipts.push(
            Receipt (
                sender,
                recipients,
                tokenAddress,
                amount,
                message
            )
        );

        uint256 sentAmount = amount / recipients.length;
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC20(tokenAddress).transfer(recipients[i], sentAmount);
        }
    }
}
