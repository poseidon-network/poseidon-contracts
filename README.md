# poseidon-contracts

<img src="https://i.imgur.com/EDW8T7Q.png" alt="Poseidon X Tron" width="400" />

**poseidon-contracts** is the smart contracts based on TRON for the Posideon Dapp.

[Posideon Dapp](https://poseidon.network/tron-dapp): Next-Generation Content Layer (CDN + DSN), incentivized by TRX. Utilized unused bandwidth and storage from any NAS, desktop, or mobile devices around the world. It’s distributed, efficient, and integrates perfectly with existing internet and blockchain infrastructure.

- iOS Alpha download：https://www.pgyer.com/SszB

- Demo video: https://drive.google.com/file/d/1ST26R1qKQJUmqG_vWiZEYyUAzG9aZ7rg/

- Introduction deck: https://drive.google.com/file/d/1m2MyNDBw2jSseZ_KaNYGQ07rkAzuVg9E/

## Address on TRON mainchain

[TVcTcDVUJkVHvLWcQcnwNFLtfUYXyfWLju](https://tronscan.org/#/contract/TVcTcDVUJkVHvLWcQcnwNFLtfUYXyfWLju)

## API Document

### get instance on mainchain using TRONWEB
[TRONWEB](https://developers.tron.network/docs/tron-web-intro)

Example:

```
var instance = tronWeb.contract(abi, "TVcTcDVUJkVHvLWcQcnwNFLtfUYXyfWLju")
```
### pay

Pay to download a file

Params | Type | Description
--- | --- | ---
fileID | uint256 | The ID of a file to be donwloaded and paid.
sharer | address | The address of file sharer. ('410000000000000000000000000000000000000000' if no sharer)

Example:

```js
instance.pay(
  123,
  '410000000000000000000000000000000000000000',
).send({ callValue: 1000 });
```

### isPaid

Check if the user has paid for a file

Params | Type | Description
--- | --- | ---
fileID | uint256 | The ID of a file to be donwloaded and paid.
user | address | Address of the user

**return**

- balance: `true` or `false`

Example:

```js
instance.isPaid(123, "4171f41dfc66757fd9f7675760ef73702b30d12419").call()
```

### balanceOf

Get GAS balance of each user

Params | Type | Description
--- | --- | ---
user | address | Address of the user

**return**

- balance: uint256

Example:

```js
instance.balanceOf("4171f41dfc66757fd9f7675760ef73702b30d12419").call()
```

### getFilePrice

Get price of the file

Params | Type | Description
--- | --- | ---
fileID | uint256 | file ID

**return**

- { provider: address, price: uint256 }

Example:

```js
instance.files(123).call()
```

## License
