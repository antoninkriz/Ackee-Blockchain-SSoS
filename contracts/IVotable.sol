// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IVotable{
    function vote(address party, bool positive) external;
}