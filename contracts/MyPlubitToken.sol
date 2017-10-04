pragma solidity ^0.4.2;

import "./Owned.sol";
import "./Token.sol";
import "./Pausable.sol";

contract MyPlubitToken is Owned, Token, Pausable {
    string public constant NAME = "Plubit Token";
    string public constant symbol = "PBT";
    uint256 public constant DECIMALS = 18;
    string public version = "1.0";

    uint256 public sellPrice;
    //contracts
    address public PlubSaleDeposit        = 0x0;      // deposit address for Indorse Sale contract
    address public PlubPresaleDeposit     = 0x0;      // deposit address for Indorse Presale Contributors
    address public PlubTeamDeposit     = 0x0;      // deposit address for Indorse Vesting for team and advisors

    uint256 public constant PlubSale      = 31603785 * 10**DECIMALS;                         
    uint256 public constant PlubPreSale   = 22995270 * 10**DECIMALS;                       
    uint256 public constant PlubTeam   = 28079514 * 10**DECIMALS; 
  
  mapping (address => bool) public frozenAccount;

  
  /* Initializes contract with initial supply tokens to the creator of the contract */
  function MyPlubitToken() {
      balances[PlubSaleDeposit]           = PlubSale;                                         // Deposit PBT 
      balances[PlubPresaleDeposit]        = PlubPreSale;                                      // Deposit PBT 
      balances[PlubTeamDeposit]           = PlubTeam;                                         // Deposit PBT 
      
      totalSupply = PlubSale + PlubPreSale + PlubTeam;

      Transfer(0x0,PlubSaleDeposit,PlubSale);
      Transfer(0x0,PlubPresaleDeposit,PlubPreSale);
      Transfer(0x0,PlubTeamDeposit,PlubTeam);
  }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
}


}