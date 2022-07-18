//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 private treeLevel = 3;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        uint256 nodes = 2**treeLevel * 2 - 1; // 17 
        for (uint8 i = 0; i < nodes; i++) {
            hashes.push(0);
        }
        root = 0;
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 currentIndex = index;
        uint256 currentHash = hashedLeaf;
        uint256 left;
        uint256 right;
        
        require(currentIndex < 2**treeLevel -1, "Max index exceeded");

        uint256 sumNodes = 0;
        uint256 nodesOnLevel = 0;
        hashes[currentIndex] = hashedLeaf; 

        for (uint8 i = 0; i < treeLevel; i++) {
            if (currentIndex % 2 == 0) {
                left = currentHash;
                right = hashes[currentIndex  + 1];
            } else {
                left = hashes[currentIndex - 1];
                right = currentHash;
            }

            currentHash = hash(left, right);
            currentIndex = (currentIndex-sumNodes)/2;
            nodesOnLevel =  2**(treeLevel - i);
            sumNodes = sumNodes + nodesOnLevel;
            currentIndex += sumNodes;
            hashes[currentIndex] = currentHash;
        }

        root = currentHash;
        index += 1;

        return currentIndex;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a,b,c,input);
    }

    function hash(uint256 _leftNode, uint256 _rightNode)
        internal 
        pure 
        returns (uint256)
    {
        uint256[2] memory input;
        input[0] = _leftNode;
        input[1] = _rightNode;
        return PoseidonT3.poseidon(input);
    }
}
