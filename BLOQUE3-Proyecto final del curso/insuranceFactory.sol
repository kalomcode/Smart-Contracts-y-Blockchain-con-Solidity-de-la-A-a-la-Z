// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <=0.8.10;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol"; 
import "./ERC20.sol";
import "./OperacionesBasicas.sol";

// --------------------- Contrato para la compañia de seguros --------------------- //
contract InsuranceFactory is OperacionesBasicas{

    // Instancia del contrato token
    ERC20Basic private token;

    constructor() public{
        token = new ERC20Basic(100);
        Insurance = address(this);
        Aseguradora = msg.sender;
    }

    struct cliente {
        address DireccionCliente;
        bool AutorizacionCliente;
        address DireccionContrato;
    }

    struct servicio {
        string nombreServicio;
        uint precioTokensServicio;
        bool EstadoServicio;
    }

    struct lab {
        address direccionContratoLab;
        bool ValidacionLab;
    }

    // Declaracion de las direcciones
    address Insurance;
    address payable public Aseguradora;

    // Mapeos clientes, servicios y laboratorios
    mapping(address => cliente) public MappingAsegurados;
    mapping(address => lab) public MappingLab;
    mapping(string => servicio) public MappingServicios;

    // Arrays para guardar clientes, servicios y laboratorios
    string[] private nombreServicios;
    address[] DireccionesLaboratorios;
    address[] DireccionesAsegurados;

    function FuncionOnlyAsegurados(address _direccionAsegurado) public view {
        require(MappingAsegurados[_direccionAsegurado].AutorizacionCliente == true, "No tienes permisos");  
    }

    // Modificadores y restricciones sobre asegurados y aseguradoras
    modifier OnlyAsegurados(address _direccionAsegurado) {
        FuncionOnlyAsegurados(_direccionAsegurado);
        _;
    }

    modifier OnlyAseguradora(address _direccionAseguradora) {
        require(Aseguradora == _direccionAseguradora, "No tienes permisos");
        _;
    }

    modifier Asegurado_o_Aseguradora(address _direccionAsegurado, address _direccionEntrante) {
        require( (MappingAsegurados[_direccionEntrante].AutorizacionCliente == true && _direccionAsegurado == _direccionEntrante) ||
        Aseguradora == _direccionEntrante, "No tienes permisos");
        _;
    }

    // Eventos
    event Evento_Comprado(uint256);
    event Evento_ServicionProporcionado(address, string, uint256);
    event Evento_LaboratorioCreado(address, address);
    event Evento_AseguradoCreado(address, address);
    event Evento_BajaAsegurado(address);
    event Evento_ServicioCreado(string, uint256);
    event Evento_BajaServicio(string);

    // --------------- FUNCIONES --------------- //

    function creacionLab() public {

        DireccionesLaboratorios.push(msg.sender);
        address direccionLab = address(new Laboratorio(msg.sender, Insurance));
        MappingLab[msg.sender] = lab(direccionLab, true);
        
        emit Evento_LaboratorioCreado(msg.sender, direccionLab);
    }

    function creacionContratoAsegurado() public {
        
        DireccionesAsegurados.push(msg.sender);
        address direccionAsegurado = address(new InsuranceHealthRecord(msg.sender, token, Insurance, Aseguradora));
        MappingAsegurados[msg.sender] = cliente(msg.sender, true, direccionAsegurado);

        emit Evento_AseguradoCreado(msg.sender, direccionAsegurado);
    }

    function Laboratorios() public view OnlyAseguradora(msg.sender) returns(address[] memory) {
        return DireccionesLaboratorios;
    }

    function Asegurados() public view OnlyAseguradora(msg.sender) returns(address[] memory) {
        return DireccionesAsegurados;
    }

    function consultarHistorialAsegurado(address _direccionAsegurado, address _direccionConsultor) public view 
    Asegurado_o_Aseguradora(_direccionAsegurado, _direccionConsultor) returns(string memory) {
        string memory historial = "";
        address direccionContratoAsegurado = MappingAsegurados[_direccionAsegurado].DireccionContrato;

        for(uint i=0; i < nombreServicios.length; i++) {
            if(MappingServicios[nombreServicios[i]].EstadoServicio == true &&
                InsuranceHealthRecord(direccionContratoAsegurado).ServicioEstadoAsegurado(nombreServicios[i]) == true
            ){
                (string memory nombreServicio, uint precioServicio) = InsuranceHealthRecord(direccionContratoAsegurado).HistorialAsegurado(nombreServicios[i]);
                historial = string(abi.encodePacked(historial, "(", nombreServicio, ", ", uint2str(precioServicio), ") -------- "));
            }
        }

        return historial;
    }

    function darBajaCliente(address _direccionAsegurado) public OnlyAseguradora(msg.sender) {
        MappingAsegurados[_direccionAsegurado].AutorizacionCliente = false;
        InsuranceHealthRecord(MappingAsegurados[_direccionAsegurado].DireccionContrato).darBaja;

        emit Evento_BajaAsegurado(_direccionAsegurado);
    }

    function nuevoServicio(string memory _nombreServicio, uint256 _precioServicio) public OnlyAseguradora(msg.sender) {
        MappingServicios[_nombreServicio] = servicio(_nombreServicio, _precioServicio, true);
        nombreServicios.push(_nombreServicio);

        emit Evento_ServicioCreado(_nombreServicio, _precioServicio);
    }

    function darBajaServicio(string memory _nombreServicio) public OnlyAseguradora(msg.sender) {
        require(ServicioEstado(_nombreServicio) == true, "No se ha dado de alta el servicio");
        MappingServicios[_nombreServicio].EstadoServicio = false;

        emit Evento_BajaServicio(_nombreServicio);
    }

    function ServicioEstado(string memory _nombreServicio) public view returns(bool) {
        return MappingServicios[_nombreServicio].EstadoServicio;
    }

    function getPrecioServicio(string memory _nombreServicio) public view returns(uint256 tokens) {
        require(ServicioEstado(_nombreServicio) == true, "No se ha dado de alta el servicio");

        return MappingServicios[_nombreServicio].precioTokensServicio;
    }

    function consultarServiciosActivos() public view returns(string[] memory) {
        string[] memory ServiciosActivos = new string[](nombreServicios.length);
        uint contador = 0;
        
        for(uint i=0; i < nombreServicios.length; i++){
            if(ServicioEstado(nombreServicios[i]) == true){
                ServiciosActivos[contador] = nombreServicios[i];
                contador++;
            }
        }

        return ServiciosActivos;
    }

    function compraTokens(address _asegurado, uint _numTokens) public payable OnlyAsegurados(_asegurado) {
        uint256 Balance = balanceOf();

        require(_numTokens <= Balance, "Compra un numero de Tokens inferior.");
        require(_numTokens > 0, "Compra un numero positivo de tokens");

        token.transfer(msg.sender, _numTokens);

        emit Evento_Comprado(_numTokens);
    }

    function balanceOf() public view returns(uint256 tokens){
        return (token.balanceOf(Insurance));
    }

    function generarTokens(uint _numTokens) public OnlyAseguradora(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

}

// --------------------- Contrato del Asegurado --------------------- //
contract InsuranceHealthRecord is OperacionesBasicas {

    enum Estado { alta, baja }

    struct Owner {
        address direccionPropietario;
        uint saldoPropietario;
        Estado estado;
        IERC20 tokens;
        address insurance;
        address payable aseguradora;
    }

    Owner propietario;

    constructor(address _owner, IERC20 _tokens, address _insurance, address payable _aseguradora) public {
        propietario.direccionPropietario = _owner;
        propietario.saldoPropietario = 0;
        propietario.estado = Estado.alta;
        propietario.tokens = _tokens;
        propietario.insurance = _insurance;
        propietario.aseguradora = _aseguradora;
    }

    struct ServiciosSolicitados {
        string nombreServicio;
        uint256 precioServicio;
        bool estadoServicio;
    }

    struct ServiciosSolicitadosLab {
        string nombreServicio;
        uint256 precioServicio;
        address direccionLab;
    }

    mapping(string => ServiciosSolicitados) historialAsegurado;
    ServiciosSolicitadosLab[] historialAseguradoLaboratorio;
    // ServiciosSolicitados[] serviciosSolicitados;

    event Evento_SelfDestruct(address);
    event Evento_DevolverTokens(address, uint256);
    event Evento_ServicioPagado(address, string, uint256);
    event Evento_PeticionServicioLab(address, address, string);

    modifier Only(address _direccion){
        require(_direccion == propietario.direccionPropietario, "No tienes permisos");
        _;
    }

    function HistorialAseguradoLaboratorio() public view returns(ServiciosSolicitadosLab[] memory){
        return historialAseguradoLaboratorio;
    }

    function HistorialAsegurado(string memory _servicio) public view returns(string memory nombreServicio, uint procioServicio) {
        return (historialAsegurado[_servicio].nombreServicio, historialAsegurado[_servicio].precioServicio);
    }

    function ServicioEstadoAsegurado(string memory _servicio) public view returns(bool) {
        return historialAsegurado[_servicio].estadoServicio;
    }

    function darBaja() public Only(msg.sender) {
        emit Evento_SelfDestruct(msg.sender);
        selfdestruct(msg.sender);
    }

    function CompraTokens(uint _numTokens) payable public Only(msg.sender) {
        require(_numTokens > 0, "Necesitas comprar un numero de Tokens positivo.");
        uint coste = calcularPrecioTokens(_numTokens);

        require(msg.value >= coste, "Compra menos o pon mas ethers.");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        InsuranceFactory(propietario.insurance).compraTokens(msg.sender, _numTokens);
    }

    function balanceOf() public view Only(msg.sender) returns(uint256 _balance) {
        return(propietario.tokens.balanceOf(address(this)));
    }

    function devolverTokens(uint _numTokens) public payable Only(msg.sender) {
        require(_numTokens > 0, "Necesitas devolver un numero positivo de Tokens.");
        require(_numTokens <= balanceOf(), "No tienes los Tokens que deseas devolver.");
        propietario.tokens.transfer(propietario.aseguradora, _numTokens);
        msg.sender.transfer(calcularPrecioTokens(_numTokens));

        emit Evento_DevolverTokens(msg.sender, _numTokens);
    }

    function peticionServicio(string memory _servicio) public Only(msg.sender){
        require (InsuranceFactory(propietario.insurance).ServicioEstado(_servicio) == true, "El servicio no se ha dado de alta en la aseguradora.");
        uint256 pagoTokens = InsuranceFactory(propietario.insurance).getPrecioServicio(_servicio);
        require(pagoTokens <= balanceOf(), "Necesitas comprar mas Tokes para optar a este servicio.");
        propietario.tokens.transfer(propietario.aseguradora, pagoTokens);
        historialAsegurado[_servicio] = ServiciosSolicitados(_servicio, pagoTokens, true);

        emit Evento_ServicioPagado(msg.sender, _servicio, pagoTokens);
    }

    function peticionServicioLab(address _direccionLab, string memory _servicio) public payable Only(msg.sender) {
        Laboratorio contratoLab = Laboratorio(_direccionLab);
        require(msg.value == contratoLab.ConsultarPrecioServicios(_servicio)*1 ether, "Operacion Invalida.");
        contratoLab.DarServicio(msg.sender, _servicio);
        payable(contratoLab.DirecionLab()).transfer(contratoLab.ConsultarPrecioServicios(_servicio)*1 ether);
        historialAseguradoLaboratorio.push(ServiciosSolicitadosLab(_servicio, contratoLab.ConsultarPrecioServicios(_servicio), _direccionLab));

        emit Evento_PeticionServicioLab(_direccionLab, msg.sender, _servicio);
    }

}

// --------------------- Contrato del Laboratorio --------------------- //
contract Laboratorio is OperacionesBasicas {

    address public DirecionLab;
    address contratoAseguradora;

    constructor(address _account, address _direccionContratoAseguradora) public {
        DirecionLab = _account;
        contratoAseguradora = _direccionContratoAseguradora;
    }

    mapping(address => string) public ServicioSolicitado;

    address[] public PeticionesServicios;

    mapping(address => ResultadoServicio) ResultadosServiciosLab;

    struct ResultadoServicio {
        string diagnostico_servicio;
        string codigo_IPFS;
    }

    string[] nombreServicioLab;

    mapping(string => ServicioLab) public serviciosLab;

    struct ServicioLab {
        string nombreServicio;
        uint precio;
        bool enFuncionamiento;
    }

    event Evento_ServicioFuncionando(string, uint);
    event Evento_DarServicio(address, string);

    modifier OnlyLab(address _direccion) {
        require(_direccion == DirecionLab, "No tienes permisos");
        _;
    }

    function NuevoServicioLab(string memory _servicio, uint _precio) public OnlyLab(msg.sender) {
        serviciosLab[_servicio] = ServicioLab(_servicio, _precio, true);
        nombreServicioLab.push(_servicio);

        emit Evento_ServicioFuncionando(_servicio, _precio);
    }

    function ConsultarServicios() public view returns(string[] memory) {
        return nombreServicioLab;
    }

    function ConsultarPrecioServicios(string memory _servicio) public view returns(uint) {
        return serviciosLab[_servicio].precio;
    }

    function DarServicio(address _direccionAsegurado, string memory _servicio) public {
        InsuranceFactory IF = InsuranceFactory(contratoAseguradora);
        IF.FuncionOnlyAsegurados(_direccionAsegurado);
        require(serviciosLab[_servicio].enFuncionamiento == true, "El servicio no esta activo actualmente.");
        ServicioSolicitado[_direccionAsegurado] = _servicio;
        PeticionesServicios.push(_direccionAsegurado);

        emit Evento_DarServicio(_direccionAsegurado, _servicio);
    }

    function DarResultados(address _direccionAsegurado, string memory _diagnostico, string memory _codigoIPFS) public OnlyLab(msg.sender) {
        ResultadosServiciosLab[_direccionAsegurado] = ResultadoServicio(_diagnostico, _codigoIPFS);
    }

    function VisualizarResultados(address _direccionAsegurado) public view returns(string memory _diagnostico, string memory _codigoIPFS) {
        _diagnostico = ResultadosServiciosLab[_direccionAsegurado].diagnostico_servicio;
        _codigoIPFS = ResultadosServiciosLab[_direccionAsegurado].codigo_IPFS;
    }

}