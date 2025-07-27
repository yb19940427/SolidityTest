// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArraySort {
    //array数组，target目标值
    function binarySearch(uint[] memory array, uint target) public pure returns (bool) {
        uint left = 0;
        uint right = array.length;
        
        //二分查找
        while (left < right) {
            //中间
            uint mid = left + (right - left) / 2;
            
            if (array[mid] == target) {
                return true;
            } else if (array[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        return false;
    }
    
}