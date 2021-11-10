// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {
    
    // ---------------------------------- DECLARACIONES INICIALES ---------------------------------- //
    
    // Instancia del contrato token
    ERC20Basic private token;
    
    // Direccion de Disney (owner)
    address payable public owner;
    
    // Constructor 
    constructor() public {
        token = new ERC20Basic(100000000);
        owner = msg.sender;
    }
    
    // Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }
    
    // Mapping para el registro de clientes
    mapping ( address => cliente) public Clientes;
    
    // ---------------------------------- GESTION DE TOKENS ---------------------------------- //
    
    // Function para establecer el precio de un Token 
    function PrecioTokens( uint _numTokens ) internal pure returns (uint) {
        // Conversion de Tokens a Ethers: 1 Token -> 1 ether 
        return _numTokens*(1 ether);
    }
    
    // Funcion para comprar Tokens en disney y disfrutar de las atracciones 
    function ComprarTokens( uint _numTokens ) public payable {
        // Establecer el precio de los Tokens 
        uint coste = PrecioTokens(_numTokens);
        // Se evalua el dinero que el cliente paga por los Tokens 
        require( msg.value >= coste, "Compra menos Tokens o paga con mas ether");
        // Diferencia de lo que el cliente paga 
        uint returnValue = msg.value - coste;
        // Disney retorna la cantidad de ethers al cliente 
        msg.sender.transfer(returnValue);
        // Obtencion del numero de Tokens disponibles
        uint Balance = balanceDisney();
        require(_numTokens <= Balance, "Compra un numero menor de Tokens");
        // Se transfiere el numero de Tokens al cliente
        token.transfer(msg.sender, _numTokens);
        // Registro de tokens comprados 
        Clientes[msg.sender].tokens_comprados += _numTokens;
    }
    
    // Balance de tokens del contrato disney
    function balanceDisney() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    // Visualizar el numero de tokens restantes de un Cliente 
    function MisTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }
    
    // Funcion para generar mas tokens 
    function GeneraTokens( uint _numTokens ) public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }
    
    // Modificador para controlar las funciones ejecutables por disney 
    modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // ---------------------------------- GESTION DE DISNEY ---------------------------------- //
    
    // Eventos
    event disfruta_atraccion(string, uint, address);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);
    
    // Estructura de la atraccion
    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    
    // Mapping para relacion de un nombre de una atraccion con una estructura de datos de la atraccion
    mapping(string => atraccion) public MappingAtracciones;
    
    // Array para almacenar el nombre de las atracciones 
    string[] Atracciones;
    
    // Mapping para relaccionar una identidad (cliente) con su historial en DISNEY 
    mapping(address => string[]) HistorialAtracciones;
    
    // Star Wars -> 2 Tokens
    // Toy Story -> 5 Tokens 
    // Piratas del Caribe -> 8 Tokens
    
    // Crear nuevas atracciones para DISNEY (SOLO es ejecutable por Disney)
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender) {
        // Creaccion de una atraccion en DISNEY 
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Almacenamiento en un array el nombre de la atraccion 
        Atracciones.push(_nombreAtraccion);
        // Emision del evento para la nueva atraccion
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }
    
    // Dar de baja a las atracciones en DISNEY 
    function BajaAtraccion( string memory _nombreAtraccion) public Unicamente(msg.sender){
        // El estado de la atraccion pasa a FALSE => No esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        // Emision del evento para la baja de la atraccion 
        emit baja_atraccion(_nombreAtraccion);
    }
    
    // Ver todas las atracciones de DISNEY
    function AtraccionesDisponibles() public view returns( string[] memory ) {
        return Atracciones;
    }
    
    // Funcion para subirse a una atraccion de disney y pagar en tokens 
    function SubirseAtraccion (string memory _nombreAtraccion) public {
        // Precio de la atraccion (en tokens)
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atraccion (si esta disponible para su uso)
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "Atraccion no disponible");
        // Verificar el numero de tokens que tiene el cliente para subirse a la atraccion 
        require(tokens_atraccion <= MisTokens(), "Necesitas mas Tokens para subirte a la atraccion");
        
        /* El cliente paga la atraccion en Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferenciaDisney'
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian
        para realizar la transaccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TrasnferFrom era la direccion del contrato
        */
        token.transferDisney(msg.sender, address(this), tokens_atraccion);
        // Almacenamiento en el historial de atracciones del cliente
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
        // Emision del evento para disfrutar de la atraccion 
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
    }
    
    // Visualizar el historial completo de atracciones disfrutadas por un cliente
    function HistorialDeAtracciones() public view returns (string[] memory) {
        return HistorialAtracciones[msg.sender];
    }
    
    // Funcion para que un cliente de Disney pueda devolver Tokens 
    function DevolverTokens( uint _numTokens ) public payable {
        // El numero de tokens a devolver es positivo
        require(_numTokens > 0, "Necesitas devolver una cantidad de tokens positiva.");
        // El usuario debe tener el numero de tokens que desea devolver 
        require(_numTokens <= MisTokens(),"No tienes los tokens que deseas devolver.");
        // El cliente devuelve los tokens 
        token.transferDisney(msg.sender, address(this), _numTokens);
        // Devolucion de los ethers al cliente 
        msg.sender.transfer(PrecioTokens(_numTokens));

    }
    
    // ---------------------------------- COMPRAR COMIDA EN DISNEY ---------------------------------- //    
    
    // Eventos
    event disfruta_comida(string, uint, address);
    event nueva_comida(string, uint);
    event baja_comida(string);
    
    // Estructura de la comida
    struct comida {
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }
    
    // Mapping para relacion de un nombre de una comida con una estructura de datos de la comida
    mapping(string => comida) public MappingComidas;
    
    // Array para almacenar el nombre de las comidas 
    string[] Comidas;
    
    // Mapping para relaccionar una identidad (cliente) con su historial en DISNEY 
    mapping(address => string[]) HistorialComidas;
    

    function NuevaComida(string memory _nombreComida, uint _precio) public Unicamente(msg.sender) {
     
        MappingComidas[_nombreComida] = comida(_nombreComida, _precio, true);
        
        Comidas.push(_nombreComida);
        
        emit nueva_comida(_nombreComida, _precio);
    }
    
  
    function BajaComida( string memory _nombreComida) public Unicamente(msg.sender){
        
        MappingComidas[_nombreComida].estado_comida = false;
       
        emit baja_comida(_nombreComida);
    }
    

    function ComidasDisponibles() public view returns( string[] memory ) {
        return Comidas;
    }
    
    
    function PedirComida (string memory _nombreComida) public {
     
        uint tokens_comida = MappingComidas[_nombreComida].precio_comida;
       
        require(MappingComidas[_nombreComida].estado_comida == true, "Atraccion no disponible");
    
        require(tokens_comida <= MisTokens(), "Necesitas mas Tokens para subirte a la atraccion");
  
        token.transferDisney(msg.sender, address(this), tokens_comida);
       
        HistorialAtracciones[msg.sender].push(_nombreComida);
        
        emit disfruta_comida(_nombreComida, tokens_comida, msg.sender);
    }
    
    
    function HistorialDeComidas() public view returns (string[] memory) {
        return HistorialComidas[msg.sender];
    }

}











