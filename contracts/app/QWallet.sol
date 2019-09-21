pragma solidity >=0.5.0;

import "../../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../token/QQQ.sol";
import "../compliance/Compliance.sol";


contract QWallet is Ownable {
    address public poseidonAddress;
    address public qqqAddress;
    uint256 public qqqFee;
    mapping (address => bool) public isETHTransfer;
    Compliance public compliance;
    address constant internal ZERO_ADDRESS = address(0);

    constructor(
        address _qqqAddress,
        uint256 initialQQQFee,
        address complianceAddress
    )
        public
        Ownable()
    {
        poseidonAddress = msg.sender;
        qqqAddress = _qqqAddress;
        qqqFee = initialQQQFee;
        compliance = Compliance(complianceAddress);
    }

    /**
    * @dev Transfer the given amount of QQQ to the recipient and QQQ fee to our address
    * Set the from address's isFeeGiven state to true
    *  @param to The recipient address.
    *  @param amount The number of tokens being transferred.
    */
    function transferQQQ(address to, uint amount) external {
        ERC20(qqqAddress).transferFrom(msg.sender, poseidonAddress, qqqFee);
        ERC20(qqqAddress).transferFrom(msg.sender, to, amount);
        isETHTransfer[to] = false;
    }

    /**
    * @dev Transfer ETH token to a specified address
    * @param to The address to transfer to.
    * @param amount The number of tokens being transferred.
    */
    function transferETH(address payable to, uint256 amount) external onlyOwner {
        require(amount < 0.5 ether, "Amount should be less than 0.5  Ether");
        require(canTransferETH(msg.sender, to, amount), "Not allow transfer ETH to this address");
        to.transfer(amount);
        isETHTransfer[to] = true;
    }


    /**
    * @dev Reset is ETH transfer
    * @param addr The address to transfer to.
    */
    function resetIsTransferETH(address payable addr) external onlyOwner {
        isETHTransfer[addr] = false;
    }


    /**
    * Set the amount of QQQ fee to transfer QQQ
    *  @param _qqqFee The number of qqq tokens be charged during transferQQQ.
    */
    function setQQQFee(uint256 _qqqFee) external onlyOwner {
        qqqFee = _qqqFee;
    }

    /**
     *  @dev Sets the compliance contract address to use during transfers.
     *  @param newComplianceAddress The address of the compliance contract.
     */
    function setCompliance(address newComplianceAddress) external onlyOwner {
        compliance = Compliance(newComplianceAddress);
    }

    /**
    * Set the adrress of Poseidon
    *  @param _poseidonAddress poseidon address
    */
    function setPoseidonAddress(address _poseidonAddress) external onlyOwner {
        poseidonAddress = _poseidonAddress;
    }

    /**
    *  @dev Checks if a transfer may take place between the two accounts.
    *
    *   Validates that the transfer can take place.
    *     - Ensure the transfer is compliant
    *  @param from The sender address.
    *  @param to The recipient address.
    *  @param tokens The number of tokens being transferred.
    *  @return If the transfer can take place.
    */
    function canTransferETH(address from, address to, uint256 tokens) private returns (bool) {
        return !isETHTransfer[to] && compliance.canTransfer(msg.sender, from, to, tokens);
    }

    function() external payable {
        // fallback Function
    }
}
