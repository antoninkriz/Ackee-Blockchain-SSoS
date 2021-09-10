// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IVotable.sol";


contract D21 is IVotable {
    /**
    CONSTS
    */

    // One week in seconds
    uint private constant DELTA_7DAYS = 7 * 24 * 60 * 60;

    // One week in seconds
    address private constant ADDRESS_ZERO = address(uint160(0));

    /**
    STATE
    */

    // Owner (creator) of this contract
    address immutable owner;

    // This contract's time of creation
    uint immutable deadline;

    // Mapping of voters and their addresses
    mapping(address => Voter) internal voters;

    // Mapping of parties and their addresses
    mapping(address => Party) internal parties;

    // Mapping of parties and their names
    mapping(string => address) internal partiesNames;

    // List of parties addresses
    address[] public partiesAddresses;

    /**
    CONSTRUCTOR
    */

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
        deadline = block.timestamp + DELTA_7DAYS;
    }

    /**
    MODIFIERS
    */

    // Gives access only to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");

        _;
    }

    // Locks a function X seconds after contract's creation time
    modifier lockDeadline() {
        require(block.timestamp < deadline, "Expired");

        _;
    }

    /**
    OWNER ONLY FUNCTIONS
    */

    // Add an eligible voter
    function addVoter(address voterNew) external onlyOwner lockDeadline {
        voters[voterNew] = Voter(2, 1);
    }

    /**
    PUBLIC FUNCTIONS
    */

    // Returns time till the end
    function timeTillEnd() external view returns (uint) {
        return deadline > block.timestamp
        ? deadline - block.timestamp
        : 0;
    }

    // Returns a party
    function getParty(address partyAddress) external view returns (Party memory) {
        return parties[partyAddress];
    }

    // Registers a party for an owner
    function registerParty(string calldata name) external lockDeadline {
        require(bytes(name).length != 0, "Name invalid");
        require(partiesNames[name] == ADDRESS_ZERO, "Name taken");
        require(parties[msg.sender].owner == ADDRESS_ZERO, "Already registered before");

        // Assign a party to it's owner
        partiesNames[name] = msg.sender;

        // Create a party
        parties[msg.sender] = Party(msg.sender, 0, name);

        // Add the party to the list
        partiesAddresses.push(msg.sender);
    }

    // Vote as a voter for a party
    function vote(address partyAddr, bool positive) external override lockDeadline {
        // Storage alias to save some gas
        Voter storage v = voters[msg.sender];
        Party storage p = parties[partyAddr];

        // Check if party exist (the owner's address is not 0x0000)
        require(p.owner != ADDRESS_ZERO, "No party");

        if (positive) {
            // Check if the voter has any positive votes left
            require(v.positive > 0, "No + votes");

            // Subtract the vote from the voter
            v.positive--;

            // Add the vote to the party
            p.votes += 1;
        } else {
            // Check if the voter has any negative votes left
            require(v.negative > 0, "No - votes");

            // Subtract the vote from the voter
            v.negative--;

            // Subtract the vote from the party
            p.votes -= 1;
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
        address owner;
        int64 votes;
        string name;
    }
}
