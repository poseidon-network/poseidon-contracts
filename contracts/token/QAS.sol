pragma solidity >=0.5.0;

import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "../../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../compliance/Compliance.sol";


contract QAS is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, Ownable {
    uint constant private INITIAL_SUPPLY = 10500000000e18; // 10.5 Billion
    string constant public NAME = "QAS";
    string constant public SYMBOL = "QAS";
    uint8 constant public DECIMALS = 18;

    address constant internal ZERO_ADDRESS = address(0);
    Compliance public compliance;

    constructor()
        ERC20()
        ERC20Detailed(NAME, SYMBOL, DECIMALS)
        ERC20Mintable()
        ERC20Burnable()
        Ownable()
        public
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     *  @dev Sets the compliance contract address to use during transfers.
     *  @param newComplianceAddress The address of the compliance contract.
     */
    function setCompliance(address newComplianceAddress) external onlyOwner {
        compliance = Compliance(newComplianceAddress);
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        bool transferAllowed;
        transferAllowed = canTransfer(msg.sender, to, value);
        if (transferAllowed) {
            _transfer(msg.sender, to, value);
        }
        return transferAllowed;
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
    function canTransfer(address from, address to, uint256 tokens) private returns (bool) {
        // ignore compliance rules when compliance not set.
        if (address(compliance) == ZERO_ADDRESS) {
            return true;
        }
        return compliance.canTransfer(msg.sender, from, to, tokens);
    }
}
