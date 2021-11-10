// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

// ------------------------------------
//  CANDIDATO  |   EDAD    |     ID
// ------------------------------------
//  Toni       |    20     |   12345X
//  Alberto    |    23     |   54321T
//  Joan       |    21     |   98765P
//  Javier     |    19     |   56789W

contract votacion {
    
    //Direccion del propietario del contrato
    address public owner;
    
    //constructor
    constructor () public {
        owner = msg.sender;
    }
    
    //Relacion entre el nombre del candidato y el hash de sus datos personales
    mapping(string => bytes32) ID_Candidato;
    
    //Relacion entre el nombre del candidato y el numero de votos
    mapping(string => uint) votos_Candidato;
    
    //Lista para almacenar los nombre de los candidatos
    string[] candidatos;
    
    //Lista de los hashes de la identidad de los votantes
    bytes32[] votantes;
    
    //Cualquier persona puede usar esta funcion para presentarse a las elecciones
    function Representar(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public {
        
        //Hash de los datos del candidato
        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));
        
        //Almacenar el hash de los datos del candidato ligados a su nombre
        ID_Candidato[_nombrePersona] = hash_Candidato;
        
        //Almacenamos el nombre del candidato
        candidatos.push(_nombrePersona);
    }
    
    //Funcion que nos permite ver los candidatos presentados a las elecciones
    function verCandidatos() public view returns (string[] memory) {
        
        return candidatos;
    }
    
    modifier soloUnaVotacion () {
        bytes32 hash_votante = keccak256(abi.encodePacked(msg.sender));
        for(uint i = 0; i < votantes.length; i++){
            require(hash_votante != votantes[i], "No puedes votar mas de una vez");
        }
        votantes.push(hash_votante);
        _;
    }
    
    //Los votantes van a poder votar 
    function Votar(string memory _candidato) public soloUnaVotacion() {
        votos_Candidato[_candidato]++;
        
    }
    
    //Funcion que nos permite ver la cantidad de votos de cierto candidato 
    function verVotos(string memory _candidato) public view returns(uint){
        return votos_Candidato[_candidato];
    }
    
    //Funcion auxiliar que transforma un uint a un string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    //Ver los votos de cada uno de los candidatos
    function verResultados() public view returns(string memory){
        //Guardamos en una variable string los candidatos con sus respectivos votos 
        string memory resultados = "";
        for(uint i; i < candidatos.length; i++){
            resultados = string(abi.encodePacked(resultados,"(", candidatos[i], ": ", uint2str(verVotos(candidatos[i])), ")\n"));
        }
        return resultados;
    }
    
    function Ganador() public view returns(string memory){
        
        string memory ganador = candidatos[0];
        bool empate;
        
        for(uint i = 1; i < candidatos.length; i++){
            
            if(votos_Candidato[candidatos[i]] > votos_Candidato[ganador]){
                ganador = candidatos[i];
                empate = false;
            }else if(votos_Candidato[candidatos[i]] == votos_Candidato[ganador]){
                empate = true;
            }
        }
        
        if(empate == true){
            ganador = "¡Hay un empate entre los candidatos!";
        }
        
        return ganador;
    }
}



















