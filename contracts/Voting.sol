// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 候选人名字到得票数的映射
    mapping(string => uint256) private candidateVotes;
    
    // 合约所有者
    address private owner;
    
    // 记录所有候选人名单
    string[] private candidateList;
    
    // 事件：当有人投票时触发
    event Voted(address indexed voter, string candidate);
    
    // 事件：当票数重置时触发
    event VotesReset(address indexed resetBy);
    
    // 构造函数，设置合约所有者
    constructor() {
        owner = msg.sender;
    }
    
    // 修饰器：只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 投票函数
    function vote(string memory candidate) public {
        require(bytes(candidate).length > 0, "Candidate name cannot be empty");
        
        // 如果是新候选人，添加到候选人列表
        if (candidateVotes[candidate] == 0) {
            candidateList.push(candidate);
        }
        
        candidateVotes[candidate] += 1;
        emit Voted(msg.sender, candidate);
    }
    
    // 获取候选人得票数
    function getVotes(string memory candidate) public view returns (uint256) {
        return candidateVotes[candidate];
    }
    
    // 重置所有候选人的票数（仅所有者可调用）
    function resetVotes() public onlyOwner {
        for (uint i = 0; i < candidateList.length; i++) {
            candidateVotes[candidateList[i]] = 0;
        }
        emit VotesReset(msg.sender);
    }
    
    // 获取所有候选人名单
    function getAllCandidates() public view returns (string[] memory) {
        return candidateList;
    }
}