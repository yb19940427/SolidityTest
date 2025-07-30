const { ethers } = require("hardhat")  //ethers包里面函数就可以用了

//async 异步函数
async function main() {
    //第一步创建一个Factory，合约工厂 做任何合约操作之前，加入关键字await，
    // 这个指的是做完这个操作之前，不要下一步工作，有了工厂才能执行后面的，后面要用这个
    //如果不加这个关键字，会直接去执行后面代码，可能这时候工厂还没有创建好
    //既然这了是非同步，main方法前也要加入async，非同步合约
    const fundMeFactory = await ethers.getContractFactory("FundMe")  //ethers包里面的方法
    console.log("contract deploying")
    //通过工厂去部署合约
    const fundMe = await fundMeFactory.deploy(300)  //这里只是去发送这个deploy操作，传入合约里面构造函数里面的入参
    //等待部署
    await fundMe.waitForDeployment()  //这里执行完后表示合约已经部署完成
    console.log("success,address is " + fundMe.target)  //fundMe.target表示合约的地址
    //或者单引号去写
    console.log(`success,address is ${fundMe.target}`)

    if (hre.network.config.chainId == 1115111 && process.env.ETHERSCAN_API_KEY) {
        //部署上链需要时间，我们可以等几个区块
        console.log("waiting for 5 block");
        await fundMe.deploymentTransaction().wait(5)
        verifyFundMe(fundMe.target,[300])
    } else {
        console.log("verify skip")
    }

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

}

async function verifyFundMe(fundMeAddr,args) {
    //将验证也写入js脚本里
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
    });
}

//上面部署写完后还要去执行他  =>代表传入是一个函数
main().then().catch((error) => {
    console.error(error)  //打印错误日志
    process.exit(1)  //正常退出是0，错误是1
})  //要去执行这个函数