const { task } = require("hardhat/config")

task("interact-fundme","interact fundme contract").addParam("addr","contract address").setAction(async(taskArgs,hre) => {
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    const fundMe = fundMeFactory.attach(taskArgs.addr)
    //获取账户
    const [firstAccount,secondAccount] = await ethers.getSigners()  //获取账号
    //调用合约中的fund函数，默认第一个账户
    const fundTx = await fundMe.fund({value: ethers.parseEther("0.5")}) 
    //等待交易成功 
    await fundTx.wait()  
    //查看合约balance
    const balanceOfContract = await ethers.provider.getBalance(fundMe.target)  
    console.log("balance of contract is "+balanceOfContract)

    //第二个账户调用合约中的fund函数，前面不写是默认第一个账户
    const fundTx1 = await fundMe.connect(secondAccount).fund({value: ethers.parseEther("0.5")}) 
    //等待交易成功 
    await fundTx1.wait()  
    //查看合约balance
    const balanceOfContract1 = await ethers.provider.getBalance(fundMe.target)  
    console.log("balance of contract is " + balanceOfContract1)

    //查看mapping,返回金额
    const firstBalance = await fundMe.fundtoAmount(firstAccount.address)
    console.log("balance firstAccount is " + firstAccount.address + " "+ firstAccount)
    const secondBalance = await fundMe.fundtoAmount(secondAccount.address)
    console.log("balance secondAccount is " + secondAccount.address + " "+ secondAccount)
})

module.exports = {

}