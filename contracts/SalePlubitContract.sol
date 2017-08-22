pragma solidity ^0.4.2;

import "./Owned.sol";
import "./Pausable.sol";
import "./MyPlubitToken.sol";
import "./MathLib.sol";

contract SaleTokenContract is Owned, Pausable, MathLib {

    MyPlubitToken    pub;

    // crowdsale parameters
    uint256 public startBlock = 1502193600;
    uint256 public endBlock   = 1504785600;
    uint256 public totalSupply;
    address public ethFundDeposit   = 0x26967201d4D1e1aA97554838dEfA4fC4d010FF6F;      // deposit address for ETH for plubit Fund
    address public plubFundDeposit   = 0x0053B91E38B207C97CBff06f48a0f7Ab2Dd81449;      // deposit address for plubit reserve
    address public plubAddress       = 0xf8e386EDa857484f5a12e4B5DAa9984E06E73705;

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in Indorse contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 1000;                                   // 1000 IND tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions

    function SalePlubitContract() {
        pub = MyPlubitToken(plubAddress);
        tokenCreationCap = pub.balanceOf(plubFundDeposit);
        isFinalized = false;
    }

    event MintPlub(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

    function CreatePlub(address to, uint256 val) internal returns (bool success) {
        MintPlub(plubFundDeposit,to,val);
        return pub.transferFrom(plubFundDeposit, to, val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new IND tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (tokenCreationCap > totalSupply);                                         // CAP reached no more please
      require (block.number >= startBlock);
      require (block.number <= endBlock);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate);                             // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      require (pub.balanceOf(msg.sender) + tokens <= maxTokens);
      
      // DA 8/6/2017 to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreatePlub(_beneficiary,tokensToAllocate));                              // Create 
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
     

      totalSupply = checkedSupply;
      require(CreatePlub(_beneficiary, tokens));                                         // logs token creation
      ethFundDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);                                            // send the eth to multi-sig
    }
 
}