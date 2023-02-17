### NFT Exponential Dutch Auction (NFTEDA)

Contracts for NFT-selling Dutch Auctions with exponential price decay.

Useful to protocols that

1. Want some guarantee of auction termination time, agnostic to price. (i.e. with 90% daily decay, after a couple days the auction could be considered "over" because it has either been purchased or the value is so low as to be negligible.)
2. Want to avoid the challenges of linear price decay: changes per second are either too small at high values or too big at low values.

Open sourcing in hopes that it is useful to others and gets wider adoption: the more searchers are looking for these CreateAuction events, the better for all the protocols that use this format!

## Audits
This code was included in [an audit of the papr protocol on Code4rena](https://code4rena.com/reports/2022-12-backed/). 