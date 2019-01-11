const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');

const tokenInterface = require('./compile').tokenData.interface;
const tokenBytecode = require('./compile').tokenData.bytecode;

const burnableInterface = require('./compile').burnableData.interface;
const burnableBytecode = require('./compile').burnableData.bytecode;

const mintableInterface = require('./compile').mintableData.interface;
const mintableBytecode = require('./compile').mintableData.bytecode;


const provider = new HDWalletProvider(
    'tiger reason cross pony hockey cereal clutch roof office track pride captain',
    'https://ropsten.infura.io/v3/32dabf89368c462cb291ee0e5f39120c'
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log(`Attempting to deploy from account ${accounts[0]}`);

    const tokenResult = await new web3.eth.Contract(tokenInterface)
        .deploy({ data: `0x${tokenBytecode}`, arguments: [] })
        .send({ gas: '5000000', from: accounts[0] });
    const tokenAddress = tokenResult.options.address;
    console.log(`token contract deployed to ${tokenResult.options.address}`);

    const burnableResult = await new web3.eth.Contract(burnableInterface)
        .deploy({ data: `0x${burnableBytecode}`, arguments: [] })
        .send({ gas: '5000000', from: accounts[0] });
    console.log(`burnable contract deployed to ${burnableResult.options.address}`);

    const mintableResult = await new web3.eth.Contract(mintableInterface)
        .deploy({ data: `0x${mintableBytecode}`, arguments: [] })
        .send({ gas: '5000000', from: accounts[0] });
    console.log(`mintable token contract deployed to ${mintableResult.options.address}`);
}

deploy();
