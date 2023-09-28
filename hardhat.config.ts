import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv'
dotenv.config({ debug: false })

let real_accounts = undefined
if (process.env.DEPLOYER_KEY) {
  real_accounts = [process.env.DEPLOYER_KEY]
}
const INFURA_API_KEY = process.env.INFURA_API_KEY

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      chainId: 5,
      accounts: real_accounts,
    },
    tbsc: {
      url: 'https://data-seed-prebsc-1-s2.binance.org:8545',
      chainId: 97,
      accounts: real_accounts,
    },
    tpolygon: {
      url: 'https://polygon-testnet-rpc.allthatnode.com:8545',
      chainId: 80001,
      accounts: real_accounts,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  }
};

export default config;
