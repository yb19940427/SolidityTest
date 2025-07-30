// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    // 代币基本信息
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    // 合约所有者
    address public owner;
    
    // 余额映射
    mapping(address => uint256) public balanceOf;
    
    // 授权映射 (owner => (spender => amount))
    mapping(address => mapping(address => uint256)) public allowance;
    
    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // 构造函数
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // 转账函数
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        //事件记录
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    // 授权函数
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // 代扣转账函数
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    // 增发代币函数（仅所有者可调用）
    function mint(uint256 _amount) public {
        require(msg.sender == owner, "Only owner can mint");
        totalSupply += _amount * (10 ** uint256(decimals));
        balanceOf[owner] += _amount * (10 ** uint256(decimals));
        emit Transfer(address(0), owner, _amount * (10 ** uint256(decimals)));
    }
    
    // 转移合约所有权
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        owner = newOwner;
    }
}