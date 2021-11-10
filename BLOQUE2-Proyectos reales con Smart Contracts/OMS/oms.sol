// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;

contract OMS_COVID {

    // Direccion de la OMS -> Owner / Dueño del contrato
    address public OMS;

    // Constructor del contrato
    constructor () {
        OMS = msg.sender;
    }

    // Mapping para relacionar los centros de salud (direccion/address) con la validez del sistema de gestion
    mapping(address => bool) public Validacion_CentrosSalud;

    // Mapping para relaccionar una direccion de un centro de salud con su contrato
    mapping(address => address) public CentroSalud_Contrato;

    // Array de direcciones que almacene los contratos de los centros de salud validados
    address[] public direcciones_contratos_salud;   

    // Array de las direcciones que soliciten acceso
    address[] public Solicitudes;

    // Eventos a emitir
    event SolicitudAcceso(address);
    event NuevoCentroValidado(address); 
    event NuevoContrato(address, address);

    // Modificador que permita unicamente la ejecucion de funciones por la OMS
    modifier OnlyOMS(address _direccion) {
        require(_direccion == OMS, 'Solo la OMS tiene permisos para ejecutar esta funcion.');
        _;
    }

    // Funcion para solicitar acceso al sistema medico
    function SolicitarAcceso() public {
        // Almacenar la direccion en el array de solicitudes
        Solicitudes.push(msg.sender);
        // Emision del evento
        emit SolicitudAcceso(msg.sender);
    }

    // Funcion que visualiza las direcciones que han solicitado este acceso
    function VisualizarSolicitudes() public view OnlyOMS(msg.sender) returns(address[] memory) {
        return Solicitudes;
    }

    // Funcion para validar nuevos centros de salud que puedan autogestionarse -> Unicamente OMS
    function CentrosSalud(address _centroSalud) public OnlyOMS(msg.sender) {
        // Asignacion del estado de validez al centro de salud
        Validacion_CentrosSalud[_centroSalud] = true;
        // Emision del evento
        emit NuevoCentroValidado(_centroSalud);
    }

    // Funcion que permita crear un contrato inteligente
    function FactoryCentroSalud() public {
        // Filtrado para que unicamente los centros de salud validados sean capaces de ejecutar esta funcion
        require(Validacion_CentrosSalud[msg.sender] == true, 'No tienes permisos para ejecutar esta funcion.');
        // Generar un contrato inteligente -> Generar su direccion
        address contrato_CentroSalud = address(new CentroSalud(msg.sender));
        // Almacenar la direccion del contrato en le array
        direcciones_contratos_salud.push(contrato_CentroSalud);
        // Relaccion entre el centro de salud y su contrato
        CentroSalud_Contrato[msg.sender] = contrato_CentroSalud;
        // Emision del evento
        emit NuevoContrato(contrato_CentroSalud, msg.sender);
    }

}

// Contrato autogestionable por el Centro de Salud
contract CentroSalud {

    // Direcciones iniciales
    address public DireccionCentroSalud;
    address public DireccionContrato;

    constructor(address _direccion) {
        DireccionCentroSalud = _direccion;
        DireccionContrato = address(this);
    }

    // Mapping que relacione una ID con un resultado de una prueba de COVID
    mapping(bytes32 => bool) ResultadoCOVID;

    // Mapping para relacionar el hash de la prueba con el codigo IPFS
    mapping(bytes32 => string) ResultadoCOVID_IPFS;

    // Eventos
    event NuevoResultado(string, bool);

    modifier OnlyCentroSalud(address _direccion) {
        require( _direccion == DireccionCentroSalud, "No tienes permisos.");
        _;
    }

}