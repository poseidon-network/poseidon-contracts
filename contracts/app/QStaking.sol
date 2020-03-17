pragma solidity ^0.5.8;
/* ERC20 interface */
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract QQQStakingPlan {
    mapping(address => bool) public authorized;
    struct StakingPlan {
        uint planType;          // type number 0: general, 1: special
        uint maxStakers;        // general: unlimited
        uint minUnits;          // default 100x
        uint lowerLimit;        // default 100 QQQ per person
        uint upperLimit;        // upper limit per subscription
        uint totalQuota;        // general: unlimited/big num
        uint bidTime;           // start to bid a plan
        uint bidOpeningPeriod;
        uint effectTime;        // The time when start to calculate profit
        uint stakingPeriod;
        uint APR;               // annual percentage rate   ex: if 20%, APR = 2000
        bool isActive;          // is this plan available
    }

    struct MySubscription {
        uint planIndex;         // StakingPlan index
        uint planType;          // 0: general, 1: special
        uint subscriptionAmount;
        uint bidTime;
        uint bidOpeningPeriod;
        uint effectTime;
        uint stakingPeriod;
        uint APR;
        bool isRedeemed;
    }

    uint[] currentStakers;
    uint[] currentStakeAmount;

    function getCurrentStakeAmountByIndex(uint _index) public view onlyOwner returns (uint) {
        return currentStakeAmount[_index];
    }

    // what user buy
    mapping(address => MySubscription[]) allSubscriptionMapping;

    StakingPlan[] public StakingPlans;
    address payable public owner; // contract creator/owner
    uint totalStakedAmount = 0;
    // address tokenContract = 0x2822f6D1B2f41F93f33d937bc7d84A8Dfa4f4C21; // mainnet QQQ
    // address tokenContract = 0x46531FBD2d0cC0ce2b89470B97627a8fdd667500; // ropsten QQQ
    address tokenContract = 0xd1d8d3fd8bc9E88c4767E46BE7ce970683F92811;  // ropsten QQQ token
    IERC20 public called_address;

    constructor() public {
        owner = msg.sender;
        called_address = IERC20(tokenContract);
        addAuthorized(0x367Aa6A1323f7c3b021Ab70c4a85eb8FB81Fd49c);
    }

    function getSubscription(address who, uint index) public view onlyOwner returns(
        uint, uint, uint, uint, uint, bool
    ){
        MySubscription memory sub = allSubscriptionMapping[who][index];
        return (
            sub.planIndex,
            sub.subscriptionAmount,
            sub.bidTime,
            sub.effectTime,
            sub.APR,
            sub.isRedeemed
        );
    }

    // function getSubscription(address who, uint index) view onlyOwner public returns(

    /**
     * @dev authorized function
     */
    function addAuthorized(address _toAdd) public onlyOwner {
        authorized[_toAdd] = true;
    }
    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != msg.sender, 'do not remove yourself');
        authorized[_toRemove] = false;
    }

    /**
     * @dev Function Modifiers
     */
    modifier onlyOwner() {
        require(authorized[msg.sender] || msg.sender == owner, 'Only Contract creator can call this');
        _;
    }

    /**
     * @dev allow contract to receive fund(eth)
     */
    function collectAll() external onlyOwner {
        uint256 amount = called_address.balanceOf(address(this));
        called_address.transfer(owner, amount);
        owner.transfer(address(this).balance);
    }

    /**
     *@dev change token address
     */
    function setTokenAddress(IERC20 _token) public onlyOwner {
        called_address = IERC20(_token);
    }

    event AddStakingPlan(uint index);

    function addStakingPlan(
        uint _planType,
        uint _maxStakers,
        uint _minUnits,
        uint _lowerLimit,
        uint _upperLimit,
        uint _totalQuota,
        uint _bidTime,
        uint _bidOpeningPeriod,
        uint _effectTime,
        uint _stakingPeriod,
        uint _APR,
        bool _isActive
    ) public onlyOwner returns(uint) {
        StakingPlans.push(StakingPlan({
            planType: _planType,
            maxStakers: _maxStakers,
            minUnits: _minUnits,
            lowerLimit: _lowerLimit,
            upperLimit: _upperLimit,
            totalQuota: _totalQuota,
            bidTime: _bidTime,
            bidOpeningPeriod: _bidOpeningPeriod,
            effectTime: _effectTime,
            stakingPeriod: _stakingPeriod,
            APR: _APR,
            isActive: _isActive
        }));

        currentStakers.push(0);
        currentStakeAmount.push(0);
        emit AddStakingPlan(StakingPlans.length - 1);
    }

    event UpdateStakingPlan(uint index, bool isActive);

    function updateStakingPlan(
        uint _index,
        bool _isActive
    ) public onlyOwner {
        StakingPlans[_index].isActive = _isActive;
        emit UpdateStakingPlan(_index, _isActive);
    }

    /**
     *@dev deposit QQQ
     */
    function deposit(
        uint _tokenAmount,
        uint planIndex
    ) public {
        if (StakingPlans[planIndex].planType == 1) { // special
            require(now > StakingPlans[planIndex].bidTime
                && now < StakingPlans[planIndex].bidTime + StakingPlans[planIndex].bidOpeningPeriod , 'Exceed time.');
        }
        require(currentStakers[planIndex] < StakingPlans[planIndex].maxStakers, 'Exceed max participants.');
        require(_tokenAmount >= (10 ** 18) * StakingPlans[planIndex].lowerLimit, 'Less than lower limit.');
        require(_tokenAmount <= (10 ** 18) * StakingPlans[planIndex].upperLimit, 'Greater than upper limit.');
        require(SafeMath.mod(_tokenAmount, ((10 ** 18) * StakingPlans[planIndex].minUnits)) == 0, 'Invalid lot size.');
        require((currentStakeAmount[planIndex] + _tokenAmount) <= (10 ** 18) * StakingPlans[planIndex].totalQuota, 'Exceed total quota.');
        require(StakingPlans[planIndex].isActive == true, 'The plan is closed.');

        // deposit token
        called_address.transferFrom(msg.sender, address(this), _tokenAmount);

        // add user subscription
        allSubscriptionMapping[msg.sender].push(MySubscription(
            planIndex,
            StakingPlans[planIndex].planType,
            _tokenAmount,
            now,
            StakingPlans[planIndex].bidOpeningPeriod,
            StakingPlans[planIndex].effectTime,
            StakingPlans[planIndex].stakingPeriod,
            StakingPlans[planIndex].APR,
            false
        ));

        // add total plan;
        currentStakers[planIndex] += 1;
        currentStakeAmount[planIndex] += _tokenAmount;

        totalStakedAmount = SafeMath.add(totalStakedAmount, _tokenAmount);
    }
    function getTotalStakedAMount() public view returns(uint) {
        return totalStakedAmount;
    }
    function getInterestAmount() public view returns(uint) {
        uint totalAmount = called_address.balanceOf(address(this));
        return totalAmount - totalStakedAmount;
    }

    function getStakingPlans(uint index) public view onlyOwner
        returns(
            uint,
            uint,
            uint,
            uint,
            uint,
            bool
        ) {
        StakingPlan memory sp = StakingPlans[index];
        return (
            currentStakers[index],
            sp.bidTime,
            sp.effectTime,
            sp.stakingPeriod,
            currentStakeAmount[index],
            sp.isActive
        );
    }
    /**
     * @dev getEstimateTokenAmount
     */
    function getEstimateTokenAmount(uint _planIndex, uint tokenAmount) public view onlyOwner returns(uint) {
        uint profit = StakingPlans[_planIndex].APR * tokenAmount / uint(10000) * StakingPlans[_planIndex].stakingPeriod / uint(86400) / 365;
        return profit;
    }
    /**
     * @dev redeemToken tokens from this contract
     */
    event RedeemTokens(uint numberOfRedeem, uint totalRedeemToken);

    function redeemTokens(address user) public onlyOwner {
        uint numberOfRedeem = 0;
        uint totalRedeemToken = 0;
        for(uint i = 0; i < allSubscriptionMapping[user].length; i++) {
            MySubscription storage userSubscriptionItem = allSubscriptionMapping[user][i];
            bool isAbleToRedeem = true;
            if (userSubscriptionItem.planType == 1) {   // special
                if (now < (StakingPlans[userSubscriptionItem.planIndex].effectTime + StakingPlans[userSubscriptionItem.planIndex].stakingPeriod)) {
                    isAbleToRedeem = false;
                }
            } else if (userSubscriptionItem.planType == 0) {    // general
                if (userSubscriptionItem.bidTime + userSubscriptionItem.stakingPeriod > now) {
                    isAbleToRedeem = false;
                }
            }

            if (isAbleToRedeem == true && userSubscriptionItem.isRedeemed == false) {
                uint profit = (userSubscriptionItem.subscriptionAmount * userSubscriptionItem.APR / uint(10000) * userSubscriptionItem.stakingPeriod / uint(86400) / 365);

                // redeem
                called_address.transfer(user, (userSubscriptionItem.subscriptionAmount + profit));
                userSubscriptionItem.isRedeemed = true;

                currentStakers[userSubscriptionItem.planIndex] -= 1;
                currentStakeAmount[userSubscriptionItem.planIndex] -= userSubscriptionItem.subscriptionAmount;

                totalStakedAmount = SafeMath.sub(totalStakedAmount, userSubscriptionItem.subscriptionAmount);

                numberOfRedeem += 1;
                totalRedeemToken += userSubscriptionItem.subscriptionAmount + profit;
            }
        }
        emit RedeemTokens(numberOfRedeem, totalRedeemToken);
    }
}