## Import wallet and keystore it

```
cast wallet import <KEY_NAME> --interactive
```

## Deploy with keystore

```
forge script script/DeploySimpleStorage.s.sol:DeploySimpleStorage --rpc-url $RPC_URL --account defaultKey --sender 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC --broadcast -vvvv
```

## Get address from keystore

```
cast wallet address --account <KEY_NAME>
```

## List keystores

```
cast wallet list
```

## Read contract

```
cast call <0x_CONTRACT> "<SIGNATURE>" --rpc-url <RPC_URL>
```

Ex.:
cast call 0xE5BFAB544ecA83849c53464F85B7164375Bdaac1 "mediaContract()" --rpc-url $RPC_ALCH

## Write contract

```
cast send <0x_CONTRACT> "<SIGNATURE>" <VALUES>
```

Ex.:
cast send 0xE5BFAB544ecA83849c53464F85B7164375Bdaac1 "removeAsk(uint256)" 33

## Unity test with --fork-url (in case you need data from deployed contracts to test)

```
forge test --mt testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL
```
