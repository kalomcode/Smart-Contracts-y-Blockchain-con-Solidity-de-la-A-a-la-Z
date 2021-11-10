pragma solidity >=0.4.4 <0.7.0;
import { Banco } from "./herencia.sol";
//import "./Banco.sol";

contract Cliente is Banco{
    
    function AltaCliente(string memory _nombre) public{
        nuevoCliente(_nombre);
    }
    
    function IngresarDinero(string memory _nombre, uint _cantidad) public{
        clientes[_nombre].dinero = clientes[_nombre].dinero + _cantidad;
    }
    
    function RetirarDinero(string memory _nombre, uint _cantidad) public returns(bool){
        
        if(clientes[_nombre].dinero < _cantidad){
            return false;
        }
        
        clientes[_nombre].dinero = clientes[_nombre].dinero - _cantidad;

        return true;
    }
    
    function ConsultarDinero(string memory _nombre) public view returns(uint){
        return clientes[_nombre].dinero;
    }
}
