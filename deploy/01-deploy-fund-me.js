const { network } = require("hardhat")
const { devlopmentChains, networkConfig, LOCK_TIME,CONFIRMATIONS } = require("../helper-hardhat-config")

module.exports = async({getNamedAccounts,deployments}) => {
    console.log("this is 01 deploy function")
    const {firstAccount} = (await getNamedAccounts())
    console.log("fund-me.js  "+firstAccount)
    const { deploy } = deployments

    let dataFeedAddr
    let confirmations
    //得到测试mock合约
    if(devlopmentChains.includes(network.name)){  
        const mockV3Aggregator = await deployments.get("MockV3Aggregator")
        dataFeedAddr = mockV3Aggregator.address
        confirmations = 0
    }else{
        dataFeedAddr = networkConfig[network.config.chainId].ethUsdDataFeed
        confirmations = CONFIRMATIONS
    }
    

    const fundMe = await deploy("FundMe",{
        from: firstAccount,
        args: [LOCK_TIME,dataFeedAddr],
        log: true,
        waitConfirmations: confirmations  //部署等待几个区块
    })

    //验证verify
    if (hre.network.config.chainId == 1115111 && process.env.ETHERSCAN_API_KEY) {
        //将验证也写入js脚本里
        await hre.run("verify:verify", {
            address: fundMe.address,
            constructorArguments: [LOCK_TIME,dataFeedAddr],
        });
    } else {
        console.log("verify skip")
    }
}

//标识
module.exports.tags=["all","fundme"]