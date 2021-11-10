// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract loteria {
    
    // Instancia del contrato Token
    ERC20Basic private token;
    
    // Direcciones
    address public owner;
    address public contrato;
    
    // Numero de tokens a crear
    uint tokens_creados = 10000;
    
    // Evento de compra de Tokens 
    event ComprandoTokens(uint, address);
    
    constructor() public {
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }
    
    // --------------------------------- TOKEN --------------------------------- //
    
    // Establecer el precio de los tokens en ethers
    function PrecioToken(uint _numTokens) internal pure returns(uint){
        return _numTokens*(1 ether);
    }
    
    // Generar mas Tokens por la Loteria 
    function GenerarToken(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    // Modificador para hacer funciones solamente accesibles por el owner del contrato
    modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion.");
        _;
    }
    
    // Comprar Tokens para comprar boletos/tickets para la loteria
    function CompraTokens(uint _numTokens) public payable {
        // Calcular el coste de los tokens 
        uint coste = PrecioToken(_numTokens);
        // Se requiere que el valor de ethers pagados sea equivalente al coste 
        require(msg.value >= coste, "Compra menos Tokens o paga con mas Ethers.");
        // Diferencia a pagar
        uint returnValue = msg.value - coste;
        // Trasferir la diferencia 
        msg.sender.transfer(returnValue);
        // Obtener el balance de Tokens del contrato
        uint Balance = TokensDisponibles();
        // Filtro para evaluar los tokens a comprar con los tokens disponibles 
        require(_numTokens <= Balance, "Compra un numero de Tokens adecuado.");
        // Transferencia de Tokens al comprador
        token.transfer(msg.sender, _numTokens);
        // Emitir el evento de compra Tokens 
        emit ComprandoTokens(_numTokens, msg.sender);
    }
    
    // Balance de tokens en el contrato de loteria 
    function TokensDisponibles() public view returns(uint) {
        return token.balanceOf(contrato);
    }
    
    // Obtener el balance de tokens acumulados en el Bote
    function Bote() public view returns(uint) {
        return token.balanceOf(owner);
    }
    
    // Cuantos Tokens tiene alguien
    function MisTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }
    
    // --------------------------------- LOTERIA --------------------------------- //
    
    // Precio del boleto en Tokens 
    uint public PrecioBoleto = 5;
    // Relacion entre la persona que compra los boletos y los numeros de los boletos
    mapping(address => uint[]) idPersona_boletos;
    // Relacion necesaria para identificar al ganador 
    mapping(uint => address) ADN_boleto;
    // Numero aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint[] boletos_comprados;
    // Eventos
    event boleto_comprado(uint, address);   // Evento cuando se compra un boleto 
    event boleto_ganador(uint);             // Evento del ganador
    event tokens_devueltos(uint, address);  // Evento tokens devueltos
    
    // Funcion para comprar boletos de loteria 
    function ComprarBoleto(uint _boletos) public {
        // Precio total de los boletos a comprar 
        uint precio_total = _boletos*PrecioBoleto;
        // Filtrado de los tokens a pagar 
        require(precio_total <= MisTokens(), "Necesitas comprar mas tokens.");
        // Transferencia de tokens al owner -> bote/premio
        token.transferLoteria(msg.sender, owner, precio_total);
        
        // Obtencion de los numeros de los boletos de forma aleatoria
        for(uint i = 0; i < _boletos; i++) {
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++;
            // Almacenamos los datos de los boletos 
            idPersona_boletos[msg.sender].push(random);
            // Numero de boleto comprado 
            boletos_comprados.push(random);
            // Asignacion del ADN del boleto para tener un ganador
            ADN_boleto[random] = msg.sender;
            // Emision del evento 
            emit boleto_comprado(random, msg.sender);
        }
    }
    
    // Visualizar el numero de boletos de una persona 
    function TusBoletos() public view returns(uint[] memory) {
        return idPersona_boletos[msg.sender];
    }
    
    // Funcion para generar un ganador y ingresarle los Tokens 
    function GenerarGanador() public Unicamente(msg.sender) {
        // Debe haber boletos comprados para generar un ganador 
        require(boletos_comprados.length > 0, "No hay boletos comprados");
        // Declaracion de la longitud del array
        uint longitud = boletos_comprados.length;
        // Aleatoriamente elijo un numero entre 0 - Longitud 
        uint posicion_array = uint(uint(keccak256(abi.encodePacked(now))) % longitud);
        // Seleccion del numero aleatorio mediante la posicion del array aleatoria 
        uint eleccion = boletos_comprados[posicion_array];
        // Emision del evento del ganador 
        emit boleto_ganador(eleccion);
        // Recuperar la direccion del ganador 
        address direccion_ganador = ADN_boleto[eleccion];
        // Enviarle los tokens del premio al ganador 
        token.transferLoteria(msg.sender, direccion_ganador, Bote());
    }
    
    // Devolucion de los tokens 
    function DevolverTokens(uint _numTokens) public payable {
        // El numero de tokens a devolver debe ser mayor a 0 
        require(_numTokens > 0, "Necesitas devolver un numero positivo de tokens.");
        // El usuario/cliente debe tener los tokens que desea devolver
        require(_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver");
        // DEVOLUCION:
        // 1. El cliente devuelva los tokens 
        // 2. La loteria paga los tokens devueltos en ethers 
        token.transferLoteria(msg.sender, address(this), _numTokens);
        msg.sender.transfer(PrecioToken(_numTokens));
        // Emision del evento 
        emit tokens_devueltos(_numTokens, msg.sender);
    }
    
}











