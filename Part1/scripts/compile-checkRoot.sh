#!/bin/bash

cd circuits

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling circuit.circom..."

# compile circuit

# circom circuit.circom --r1cs --wasm --sym -o .
circom checkRoot.circom --r1cs --wasm --sym -o .
snarkjs r1cs info checkRoot.r1cs
# snarkjs r1cs print hasher.r1cs hasher.sym
# Start a new zkey and make a contribution

snarkjs groth16 setup checkRoot.r1cs powersOfTau28_hez_final_10.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

node ./checkRoot_js/generate_witness.js ./checkRoot_js/checkRoot.wasm inputCheckRoot.json witness.wtns

# generate solidity contract
# snarkjs zkey export solidityverifier circuit_final.zkey ../contracts/verifier.sol

snarkjs groth16 prove circuit_final.zkey witness.wtns proofcheckRoot.json publiccheckRoot.json

snarkjs groth16 verify verification_key.json publiccheckRoot.json proofcheckRoot.json

cd ..