const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { assert, expect } = require("chai")
const helpers = require("@nomicfoundation/hardhat-network-helpers")
const {devlopmentChains} = require("../../helper-hardhat-config")

//集成测试
devlopmentChains.includes(network.name)
? describe.skip
: describe("test fundme contract", async function() {
    let fundMe
    let firstAccount
    beforeEach(async function() {
        await deployments.fixture(["all"])
        firstAccount = (await getNamedAccounts()).firstAccount
        const fundMeDeployment = await deployments.get("FundMe")
        fundMe = await ethers.getContractAt("FundMe", fundMeDeployment.address)
    })

    // test fund and getFund successfully
    it("fund and getFund successfully", 
        async function() {
            // 达到target
            await fundMe.fund({value: ethers.parseEther("0.5")}) // 3000 * 0.5 = 1500
            // 保证达到足够时间，Promise等待一段时间，超过180s
            await new Promise(resolve => setTimeout(resolve, 181 * 1000)) 
            // 发送完后有没有回执，保证可以收到回执，等待交易成功入块
            const getFundTx = await fundMe.getFund()
            const getFundReceipt = await getFundTx.wait()
            //通过回执expect
            expect(getFundReceipt)
                .to.be.emit(fundMe, "FundWithdrawByOwner")
                .withArgs(ethers.parseEther("0.5"))
        }
    )
    // test fund and refund successfully
    it("fund and refund successfully",
        async function() {
            await fundMe.fund({value: ethers.parseEther("0.1")}) // 3000 * 0.1 = 300
            await new Promise(resolve => setTimeout(resolve, 181 * 1000))
            const refundTx = await fundMe.refund()
            const refundReceipt = await refundTx.wait()
            expect(refundReceipt)
                .to.be.emit(fundMe, "RefundByFunder")
                .withArgs(firstAccount, ethers.parseEther("0.1"))
        }
    )
    

})