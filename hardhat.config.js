require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config()
require("./tasks")
require("hardhat-deploy")
require("@nomicfoundation/hardhat-ethers");
require("hardhat-deploy");
require("hardhat-deploy-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
const SEPOLIA_URL = process.env.SEPOLIA_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const PRIVATE_KEY1 = process.env.PRIVATE_KEY1
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  defaultNetwork: "hardhat",
  mocha:  {
    timeout: 300000 /** 300s,默认40s就会超时，但是真正部署时间不够用 */ 
  },
  networks: {
    sepolia: {
      /** 第三方api地址 */
      url:  SEPOLIA_URL,
      /** 私钥地址 */
      accounts: [PRIVATE_KEY,PRIVATE_KEY1],
      chainId:  1115111
    }
  },
  /** 想要在etherscan里面验证需要用到一个apiKey */
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY
    }
  },
  namedAccounts: {
    firstAccount: {
      default: 0
    },
    secondAccount: {
      default: 1
    }
  },
  // gasReporter: {
  //   enabled: false
  // }
};
