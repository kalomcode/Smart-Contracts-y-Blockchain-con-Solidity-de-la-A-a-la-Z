 pragma solidity >=0.4.4 <0.7.0;
import "./ERC20";

contract PrimerContrato{
    
    address owner;
    ERC20Basic token;
    
    constructor() public{
        owner = msg.sender;
        token = new ERC20Basic(1000);
        
    }
    
}
