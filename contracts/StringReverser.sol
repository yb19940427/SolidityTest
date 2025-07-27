// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringReverser {
    function reverse(string memory _str) public pure returns (string memory) {
        // 将字符串转换为bytes类型
        bytes memory strBytes = bytes(_str);
        bytes memory reversed = new bytes(strBytes.length);
        
        // 反转操作
        for(uint i = 0; i < strBytes.length; i++) {
            reversed[i] = strBytes[strBytes.length - i - 1];
        }
        
        return string(reversed);
    }
}