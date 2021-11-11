// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <=0.8.10;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol"; 
import "./ERC20.SOL";
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

    constructor(address _owner, IERC20 _token, address _insurance, address payable _aseguradora) public {
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

    mapping(string => ServiciosSolicitados) hstorialAsegurado;
    ServiciosSolicitadosLab[] historialAseguradoLaboratorio;
    // ServiciosSolicitados[] serviciosSolicitados;

    function HistorialAseguradoLaboratorio() public view returns(ServiciosSolicitadosLab[] memory){
        return historialAseguradoLaboratorio;
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

}