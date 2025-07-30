// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//这个是预言机
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//创建一个收款函数
//记录投资人，查看
//在锁定期间内，达到目标值，提款，没有达到，退款

contract FundMe {

    //记录投资人,投资金额
    mapping (address => uint256) public fundtoAmount;

    //最小额度,用的单位是wei
    uint256 constant MINIMUM_USD = 10 * 10 ** 18;
    // 1 eth = 1000000000000000000 wei

    //设定一个目标值,不会修改就定义为常量
    uint256 constant TARGET = 100 * 10 ** 18;

    //合约作为了类型，只有在合约内部函数可以调用
    AggregatorV3Interface public dataFeed;

    //设置一个管理者owner，有些函数只有owner才能去调用
    address public owner;

    //合约部署时间,solidity中时间就是整数 秒
    uint256 deploymentTimestamp;
    //锁定时间，锁定多久
    uint256 lockTime;

    //ERC20合约地址
    address erc20Addr;
    //设置一个变量记录状态
    bool public getFundSuccess;
    //提取金额触发一个参数
    event FundWithdrawByOwner(uint256);
    //address地址，谁去refund
    event RefundByFunder(address,uint256);

    //对AggregatorV3Interface合约初始化，第三方服务要去测试网去测试，本地无法测试的，这里要用引入的合约，你就要写入合约的地址，这样才能调用
    //这里用的是AggregatorV3Interface在sepolia测1试网上的地址  0x694AA1769357215DE4FAC081bf1f309aDC325306，eth对usd的价格
    constructor(uint256 _lockTime, address dataFeedAddr) {
        dataFeed = AggregatorV3Interface(dataFeedAddr);
        owner = msg.sender;  //获取当时部署合约的地址，赋给owner作为管理者
        deploymentTimestamp = block.timestamp;  //当前区块部署的时间点，找出来，给到deploymentTimestamp
        //锁定时间自己输入
        lockTime = _lockTime;
    }

    //chainlink喂价  预言机

    //收款函数,payable收款，发起账户地址转入了合约中，合约就有钱了，合约余额变化了，多了
    function fund() external payable {
        //这里调用函数，反回价格是美元价格，然后和MINIMUM_USD去比较
        require(converEthToUsd(msg.value) >= MINIMUM_USD, "you need to spend more ETH!");
        //这个说明处于时间区间以内，可以操作
        require(block.timestamp <= deploymentTimestamp + lockTime, "lock time is over");
        fundtoAmount[msg.sender] += msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    //去查询价格，然后数量乘以价格，价格也变成10的18次方,价格是美元的价格  eth数量*美元价格，就是总的美元价格
    function converEthToUsd(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice/(10 ** 8);
    }

    //这里要看谁可以去转移资产
    function getFund() external windowClosed onlyOwner{
        //获取合约地址,获取余额，获取到的是wei为单位的eth数量，这里要转换成usd的值，然后去比较
        require(converEthToUsd(address(this).balance) >= TARGET,"Target is not4 reached");
        //require(msg.sender == owner, "");  //这个函数只能当前调用者这个地址去调用
        //require(block.timestamp >= deploymentTimestamp + lockTime, "lock time is over");
        //transfer,send,纯转账  call可以加数据，所以就使用call就行了
        //payable(msg.sender).transfer(address(this).balance);
        bool success;
        uint256 balance = address(this).balance;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");  //call加数据，就可以加数据，这样就可以了
        require(success,"failed");
        //清零
        fundtoAmount[msg.sender] = 0;
        getFundSuccess = true;
        //emit event  类似于一个日志，发出一个事件
        emit FundWithdrawByOwner(balance);

    }
    

    //修改合约的owner
    function transferOwnership(address newOwner) public onlyOwner{
        //equire(msg.sender == owner, "");  //这个函数只能当前调用者这个地址去调用
        owner = newOwner;
    }

    function refund() external windowClosed{
        require(converEthToUsd(address(this).balance) < TARGET,"Target is reached");
        //退款,查看当前地址有没有交过钱
        require(fundtoAmount[msg.sender] != 0,"no fund");
        //require(block.timestamp >= deploymentTimestamp + lockTime, "lock time is over");
        bool success;
        uint256 balance = fundtoAmount[msg.sender];
        (success, ) = payable(msg.sender).call{value: fundtoAmount[msg.sender]}("");  //call加数据，就可以加数据，这样就可以了
        require(success,"failed");
        //清零
        fundtoAmount[msg.sender] = 0;
        //事件
        emit RefundByFunder(msg.sender,balance);
    }

    //修改器
    modifier windowClosed(){
        require(block.timestamp >= deploymentTimestamp + lockTime, "lock time is over");
        _;  //这里是指下面要执行的函数  下划线放在下面，先执行上面的，然后执行其他下面的代码，这里require排在前面
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "");  //这个函数只能当前调用者这个地址去调用
        _;  //这里是指下面要执行的函数  下划线放在下面，先执行上面的，然后执行其他下面的代码，这里require排在前面
    }

    //判断地址是否是erc20的地址，是的话才能更新
    function setFunderToAmount(address funder,uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr, "not permission");
        fundtoAmount[funder] = amountToUpdate;
    }

    //设置ERC20合约地址
    function setErc20Addr(address addr) public onlyOwner {
        erc20Addr = addr;
    }

}