# NOTE:

There are two branches: `main` and `least-gas-used-to-vote`.

`main` consist of I think better and more readable code with no optimizations whatsoever.  
`least-gas-used-to-vote` is (somewhat) optimized code **without** _reentrancy attack_ checks.  

I was not really sure if we should worry about _reentrancy attacks_, so I made two versions.

## Gas estimations for the `vote` function

**State**: 1 voter, 1 party; solcjs 0.8.7

branch | positive vote gas | negative vote gas
-------|-------------------|-------------------
`main` | 77552 | 77680
`least-gas-used-to-vote` | 38197 | 38325


---

# Summer School of Solidity (SSoS) 2021

SSoS assignment

## Voting system smart contract
### Janečkova metoda D21 (2 positive, 1 negative)
- UC1 - Everyone can register a party
- UC2 - Only the owner can add eligible voters
- UC3 - Voting ends after 7 days from contract deployment 
- UC4 - Everyone can see remaining time to end
- UC5 - Everyone can fetch live results
- Bonus task: vote() method gas contest
