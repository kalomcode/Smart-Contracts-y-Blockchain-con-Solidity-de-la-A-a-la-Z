pragma solidity >=0.4.4 <0.7.0;

contract Modifier {
    
    //Ejemplo de solo propietario del contrato puede ejecutar una function
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier soloPropietario(){
        require(msg.sender == owner, "Notienes permisos para ejecutar la funcion");
        _;
    }
    
    function ejemplo1() public soloPropietario(){
        //Codigo de la funcion para el propietario del contrato
    }                     
    
    struct cliente {
        address direccion;
        string nombre;
    }
    
    mapping(string => address) clientes;
    
    function altaCliente(string memory _nombre) public {
        clientes[_nombre] = msg.sender;
    }
    
    modifier soloClientes(string memory _nombre){
        require(clientes[_nombre] == msg.sender);
        _;
    }
    
    function ejemplo2(string memory _nombre) public soloClientes(_nombre) {
        //logica de la funcion para los clientes
    }
    
    //Ejemplo de conduccion
    
    modifier MayorEdad(uint _edadMinima, uint _edadUsuario){
        require(_edadUsuario >= _edadMinima);
        _;
    }
    
    function conducir(uint _edad) public MayorEdad(18, _edad){
        //Codigo a ejecutar para los conductores mayores de edad
    }
}




