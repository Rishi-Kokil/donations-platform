require("@matterlabs/hardhat-zksync-solc");
require('dotenv').config(); // To load environment variables

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "rsk_testnet", // Set default network to RSK testnet
  networks: {
    hardhat: {},
    rsk_testnet: {
      url: 'https://public-node.testnet.rsk.co', // RSK Testnet RPC URL
      chainId: 31, // Chain ID for RSK Testnet
      accounts: [`0x${process.env.PRIVATE_KEY}`], // Using private key from .env
      gas: "auto", // You can adjust gas limits if needed
      gasPrice: 0x387EE40, // Approx 0.001 RBTC gas price (25 Gwei in Wei)
    },
    rsk_mainnet: {
      url: 'https://public-node.rsk.co', // RSK Mainnet RPC URL (for future deployment)
      chainId: 30, // Chain ID for RSK Mainnet
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      gas: "auto",
      gasPrice: 0x387EE40, // Adjust gas price according to the mainnet
    },
  },
};
