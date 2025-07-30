// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {
    // 合约所有者
    address payable public owner;
    
    // 记录每个捐赠者的捐赠总额
    mapping(address => uint256) public donations;
    
    // 总捐赠金额
    uint256 public totalDonations;
    
    // 事件：记录捐赠
    event Donated(address indexed donor, uint256 amount);
    
    // 事件：记录提款
    event Withdrawn(address indexed owner, uint256 amount);
    
    // 构造函数，设置合约所有者
    constructor() {
        owner = payable(msg.sender);
    }
    
    // 修饰器：仅所有者可调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 捐赠函数（payable）
    function donate() public payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        // 记录捐赠
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        
        emit Donated(msg.sender, msg.value);
    }
    
    // 查询指定地址的捐赠金额
    function getDonation(address _donor) public view returns (uint256) {
        return donations[_donor];
    }
    
    // 提款函数（仅所有者）
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // 转账给所有者
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(owner, balance);
    }
    
    // 获取合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}