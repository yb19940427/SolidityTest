const { DECIMAL,INITIAL_ANSWER,devlopmentChains} = require("../helper-hardhat-config")

module.exports = async({getNamedAccounts,deployments}) => {
    if(devlopmentChains.includes(network.name)){ 
        console.log("this is 00 deploy function")
        const {firstAccount} = (await getNamedAccounts())
        console.log("mock "+firstAccount)
        const { deploy } = deployments
        await deploy("MockV3Aggregator",{
            from: firstAccount,
            args: [DECIMAL,INITIAL_ANSWER],
            log: true
        })
    }else{
        console.log("environment is note local")
    }
}

//标识
module.exports.tags=["all","mock"]