pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";


contract QQQ is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable {
    uint private INITIAL_SUPPLY = 10000e18;

    constructor() public
        ERC20Burnable()
        ERC20Mintable()
        ERC20Detailed("QQQToken", "QQQ", 18)
        ERC20()
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
