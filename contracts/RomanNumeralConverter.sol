// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanNumeralConverter {
    // 定义罗马数字符号及其对应的值
    struct RomanNumeral {
        uint256 value;
        string symbol;
    }
    
    // 罗马数字符号表，按从大到小排序
    RomanNumeral[] private romanNumerals;
    
    constructor() {
        // 初始化罗马数字符号表
        romanNumerals.push(RomanNumeral(10, "X"));
        romanNumerals.push(RomanNumeral(9, "IX"));
        romanNumerals.push(RomanNumeral(5, "V"));
        romanNumerals.push(RomanNumeral(4, "IV"));
        romanNumerals.push(RomanNumeral(1, "I"));
    }
    
    // 将整数转换为罗马数字
    function intToRoman(uint256 num) public view returns (string memory) {
        require(num > 0 && num < 4000, "Number must be between 1 and 3999");
        
        bytes memory roman;
        
        for (uint256 i = 0; i < romanNumerals.length; i++) {
            while (num >= romanNumerals[i].value) {
                roman = abi.encodePacked(roman, romanNumerals[i].symbol);
                num -= romanNumerals[i].value;
            }
        }
        
        return string(roman);
    }
}