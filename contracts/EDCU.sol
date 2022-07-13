// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Edcu is ERC20{
    constructor() ERC20("EDCU", "AXYZ LMS Token") {}
}