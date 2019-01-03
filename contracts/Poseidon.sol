pragma solidity ^0.4.22;

import './GAS.sol';


contract Poseidon is GAS{
    address constant public pool = address(1);
    address public oracle;
    address public poseidon;
    uint256 public trxPrice;

    mapping (uint256 => File) public files;
    mapping (uint256 => bool) public isDispatched;
    mapping (uint256 => mapping(address => bool)) public isPaid;

    struct File {
        address provider;
        uint256 price;
    }

    modifier onlyOracle() {
        require (msg.sender == oracle);
        _;
    }

    constructor() {
        oracle = msg.sender;
    }

    // owner function
    function transferOracle (address _user) external onlyOracle {
        oracle = _user;
    }

    function setTrxPrice (uint256 _trxPrice) external onlyOracle {
        trxPrice = _trxPrice;
    }

    function setPoseidonAddress (address _poseidon) external onlyOracle {
        poseidon = _poseidon;
    }

    function register (uint256 fileId, address provider, uint256 price) external onlyOracle {
        require (provider != address(0));
        require (files[fileId].provider == address(0));
        files[fileId] = File(provider, price);
    }

    function updateFilePrice (uint256 fileId, uint256 price) external onlyOracle {
        address provider = files[fileId].provider;
        require (provider != address(0));
        files[fileId] = File(provider, price);
    }

    function dispatch (address[] users, uint256[] amounts, uint256 dispatchId) external onlyOracle {
        require (!isDispatched[dispatchId]);
        for (uint256 i = 0; i < users.length; i++) {
            require(_transfer(this, users[i], amounts[i]));
        }
        isDispatched[dispatchId] = true;
    }

    function withdrawTrx () external onlyOracle {
        oracle.transfer(this.balance);
    }

    // user function
    function pay(uint256 fileId, address sharer) external payable {
        require (isPaid[fileId][msg.sender] == false);
        File memory file = files[fileId];
        require (file.provider != address(0));
        uint256 price = file.price * 95 / 100;
        uint256 paied = msg.value * trxPrice / 100000;
        require(paied > price);
        mint(sharer, file.provider, file.price);
        isPaid[fileId][msg.sender] = true;
    }

    // internal function
    function mint(address sharer, address provider, uint256 amount) internal {
        totalSupply_ += amount;
        if (sharer == address(0)) {
            balances[poseidon] += amount * 30 / 100;
            emit Transfer(address(0), poseidon, amount * 30 / 100);
        } else {
            balances[sharer] += amount * 20 / 100;
            balances[poseidon] += amount * 10 / 100;
            emit Transfer(address(0), sharer, amount * 20 / 100);
            emit Transfer(address(0), poseidon, amount * 10 / 100);
        }
        balances[provider] += amount * 30 / 100;
        emit Transfer(address(0), provider, amount * 30 / 100);
        balances[pool] += amount * 40 / 100;
        emit Transfer(address(0), pool, amount * 40 / 100);
    }
}
