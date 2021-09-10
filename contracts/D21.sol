// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IVotable.sol";


contract D21 is IVotable {
    /**
    CONSTS
    */

    // One week in seconds
    uint64 constant DELTA_7DAYS = 7 * 24 * 60 * 60;

    /**
    STATE
    */

    // Owner (creator) of this contract
    address immutable owner;

    // This contract's time of creation
    uint immutable createdAt;

    // Mapping of voters and their addresses
    mapping (address => Voter) public voters;

    // Mapping of parties and their addresses
    mapping (address => Party) public parties;

    // Mapping of parties and their names
    mapping (string => address) public partiesNames;

    /**
    CONSTRUCTOR
    */

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
        createdAt = block.timestamp;
    }

    /**
    MODIFIERS
    */

    // Prevents reentrancy attack. Source: https://solidity-by-example.org/function-modifier/
    bool locked;
    modifier noReentrancy() {
        require(!locked, "No reentrancy");

        locked = true;
        _;
        locked = false;
    }

    // Gives access only to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");

        _;
    }

    // Locks a function X seconds after contract's creation time
    modifier maxSecondsSinceCreation(uint64 delta) {
        require(block.timestamp < createdAt + delta, "Expired");

        _;
    }

    /**
    PURE FUNCTIONS
    */

    // Returns true when the calldata string is empty
    function strEmpty(string calldata s) internal pure returns(bool) {
        return bytes(s).length == 0;
    }

    // Returns true when the storage string is empty
    function strEmpty(string storage s) internal view returns(bool) {
        return bytes(s).length == 0;
    }

    // Returns true when the address is zero
    function addressIsZero(address adr) internal pure returns(bool) {
        return adr == address(uint160(0));
    }

    /**
    OWNER ONLY FUNCTIONS
    */

    // Add an eligible voter
    function addVoter(address voterNew) external onlyOwner maxSecondsSinceCreation(DELTA_7DAYS) {
        voters[voterNew] = Voter(2, 1);
    }

    /**
    PUBLIC FUNCTIONS
    */

    // Returns time till the end
    function timeTillEnd() external view returns(int) {
        return int(createdAt + DELTA_7DAYS) - int(block.timestamp);
    }

    // Registers a party for an owner
    function registerParty(string calldata name) external noReentrancy maxSecondsSinceCreation(DELTA_7DAYS) {
        require(!strEmpty(name), "Name invalid");
        require(addressIsZero(partiesNames[name]), "Name taken");
        require(strEmpty(parties[msg.sender].name), "Already registered before");

        // Assign a party to it's owner
        partiesNames[name] = msg.sender;

        // Create a party
        parties[msg.sender] = Party(name, 0);
    }

    // Vote as a voter for a party
    function vote(address party, bool positive) external noReentrancy override maxSecondsSinceCreation(DELTA_7DAYS) {
        // Check if party exist (the owner's address is not 0x0000)
        require(!strEmpty(parties[party].name), "Party does not exist");

        if (positive) {
            // Check if the voter has any positive votes left
            require(voters[msg.sender].positive > 0, "No positive votes");

            // Subtract the vote from the voter
            voters[msg.sender].positive--;

            // Add the vote to the party
            parties[party].votes += 1;
        } else {
            // Check if the voter has any negative votes left
            require(voters[msg.sender].negative > 0, "No negative votes");

            // Subtract the vote from the voter
            voters[msg.sender].negative--;

            // Subtract the vote from the party
            parties[party].votes -= 1;
        }
    }

    /**
    STRUCTS
    */

    // Structure holding remaining number of votes of a voter
    struct Voter {
        uint8 positive;
        uint8 negative;
    }

    // Structure holding current information about a party
    struct Party {
        string name;
        int votes;
    }
}
