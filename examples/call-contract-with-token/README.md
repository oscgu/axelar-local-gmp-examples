# Axelar bounty

## What

Cross-chain transactions, with a receipt saved on the destination chain

## How

I added the necessary code to create and save receipts upon receiving a transaction.  
Then I edited the `../info/testnet.json` file and deleted all chains except the ones I  
intend to use (Moonbeam and Polygon). After that I had to change `index.js` so that you can pass  
a message and increased the gas limit + value.  
I also had to add a private key to the `.env` file  
Now it was time to deploy everything, so I ran: `node scripts/deploy examples/call-contract-with-token testnet`  
After that I put the contract addresses into the `../info/testnet.json" file as the destinationDistributionExecutable field and tested the contracts with the following command:  
`node scripts/test examples/call-contract-with-token testnet "Moonbeam" "Polygon" 1 0xcDCDcb021Fa5Ae6aD6cc603A46eB24EE5B5bac1b "hey fren"`

and got the following console output:  
```
--- Initially ---
0xcDCDcb021Fa5Ae6aD6cc603A46eB24EE5B5bac1b has 9.85 aUSDC on source
0xcDCDcb021Fa5Ae6aD6cc603A46eB24EE5B5bac1b has 0 aUSDC on dest
--- After ---
0xcDCDcb021Fa5Ae6aD6cc603A46eB24EE5B5bac1b has 8.85 aUSDC on source
0xcDCDcb021Fa5Ae6aD6cc603A46eB24EE5B5bac1b has 1 aUSDC on dest
```

And looked the transaction hash up:

https://testnet.axelarscan.io/gmp/0x9110cee19d2184d46dcc647a7ddb3a8036a1ad2f75eacd938e5d7cf161252d4a:6  

It worked! :)
