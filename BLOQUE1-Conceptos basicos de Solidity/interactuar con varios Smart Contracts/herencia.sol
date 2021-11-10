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










