// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArrayMerger {
    // 合并两个有序数组
    function mergeSortedArrays(uint[] memory a, uint[] memory b) 
    public 
    pure 
    returns (uint[] memory) {
        //定义合并数组长度
        uint[] memory merged = new uint[](a.length + b.length);
        uint i = 0;
        uint j = 0;
        uint k = 0;
        
        // 比较两个数组元素并按顺序合并
        while (i < a.length && j < b.length) {
            if (a[i] < b[j]) {
                merged[k++] = a[i++];
            } else {
                merged[k++] = b[j++];
            }
        }
        
        // 将剩余元素复制到合并数组
        while (i < a.length) {
            merged[k++] = a[i++];
        }
        
        while (j < b.length) {
            merged[k++] = b[j++];
        }
        
        return merged;
    }
}