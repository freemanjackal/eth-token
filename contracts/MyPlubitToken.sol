pragma solidity ^0.4.2;

import "./Owned.sol";
import "./Token.sol";
import "./BasicToken.sol";

contract MyEthToken is Owned, Token {
    string public constant NAME = "Plubit Token";
    string public constant symbol = "PBT";
    uint256 public constant DECIMALS = 18;
    string public version = "1.0";

    uint256 public sellPrice;
    //contracts
    address public PlubSaleDeposit        = 0x0053B91E38B207C97CBff06f48a0f7Ab2Dd81449;      // deposit address for Indorse Sale contract
    address public PlubSeedDeposit        = 0x0083fdFB328fC8D07E2a7933e3013e181F9798Ad;      // deposit address for Indorse Seed Contributors
    address public PlubPresaleDeposit     = 0x007AB99FBf023Cb41b50AE7D24621729295EdBFA;      // deposit address for Indorse Presale Contributors
    address public PlubVestingDeposit     = 0x0011349f715cf59F75F0A00185e7B1c36f55C3ab;      // deposit address for Indorse Vesting for team and advisors

    uint256 public constant PlubSale      = 31603785 * 10**DECIMALS;                         
    uint256 public constant PlubSeed      = 3566341 * 10**DECIMALS; 
    uint256 public constant PlubPreSale   = 22995270 * 10**DECIMALS;                       
    uint256 public constant PlubVesting   = 28079514 * 10**DECIMALS; 
  
  mapping (address => bool) public frozenAccount;

  
  /* Initializes contract with initial supply tokens to the creator of the contract */
  function MyPlubitToken(
      uint256 initialSupply,
      string tokenName,
      uint8 decimalUnits,
      string tokenSymbol
  ) Token (initialSupply, tokenName, decimalUnits, tokenSymbol)
  {

      totalSupply = PlubSale + PlubSeed + PlubPreSale + PlubVesting;

      Transfer(0x0,PlubSaleDeposit,PlubSale);
      Transfer(0x0,PlubSeedDeposit,PlubSeed);
      Transfer(0x0,PlubPresaleDeposit,PlubPreSale);
      Transfer(0x0,PlubVestingDeposit,PlubVesting);
  }

  /* Internal transfer, only can be called by this contract */
  function _transfer(address _from, address _to, uint _value) internal {
      require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
      require (balanceOf[_from] > _value);                // Check if the sender has enough
      require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
      balanceOf[_from] -= _value;                         // Subtract from the sender
      balanceOf[_to] += _value;                           // Add the same to the recipient
      Transfer(_from, _to, _value);
  }

  /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
  /// @param newSellPrice Price the users can sell to the contract
  /// @param newBuyPrice Price users can buy from the contract
  function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
      sellPrice = newSellPrice;
  }


  /// @notice Sell `amount` tokens to contract
  /// @param amount amount of tokens to be sold
  function sendPlubits(uint256 amount) {
      require(this.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
      _transfer(this, msg.sender, amount);              // makes the transfers
      msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
  }



}