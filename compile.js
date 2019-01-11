const path = require('path');
const fs = require('fs');
const solc = require('solc');

const tokenPath = path.resolve(__dirname , 'contracts', 'Token.sol');
const burnablePath = path.resolve(__dirname, 'contracts', 'TokenBurnable.sol');
const mintablePath = path.resolve(__dirname, 'contracts', 'TokenMintable.sol');

const tokenSource = fs.readFileSync(tokenPath, 'utf-8');
const burnableSource = fs.readFileSync(burnablePath, 'utf-8');
const mintableSource = fs.readFileSync(mintablePath, 'utf-8');


const input = {
    language: 'Solidity',
    sources: {
        'Token.sol': {
            'content': tokenSource
        },
        'TokenBurnable.sol': {
            'content': burnableSource
        },
        'TokenMintable.sol': {
            'content': mintableSource
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            },
        },
    }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

console.log(output);

module.exports = {
    tokenData: {
        interface: output.contracts['Token.sol'].Token.abi, 
        bytecode: output.contracts['Token.sol'].Token.evm.bytecode.object
    },
    burnableData: {
        interface: output.contracts['TokenBurnable.sol'].TokenBurnable.abi, 
        bytecode: output.contracts['TokenBurnable.sol'].TokenBurnable.evm.bytecode.object
    },
    mintableData: {
        interface: output.contracts['TokenMintable.sol'].TokenMintable.abi,
        bytecode: output.contracts['TokenMintable.sol'].TokenMintable.evm.bytecode.object
    }
};