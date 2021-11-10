pragma solidity >=0.4.4 <0.7.0;

contract Banco{
    
    //Definimos un tipo de dato complejo cliente
    struct cliente{
        string _nombre;
        address direccion;
        uint dinero;
    }
    
    //mapping que nos relaciona el nombre del cliente con el tipo de dato cliente
    mapping (string => cliente) clientes;
    
    //Funcion que nos permita dar de alta a un cliente
    function nuevoCliente(string memory _nombre) public{
        clientes[_nombre] = cliente(_nombre, msg.sender, 0);
    }
}