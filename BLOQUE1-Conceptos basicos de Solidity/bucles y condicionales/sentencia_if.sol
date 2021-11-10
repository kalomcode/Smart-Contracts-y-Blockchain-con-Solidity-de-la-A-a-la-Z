pragma solidity >=0.4.4 <0.7.0;

contract sentencia_if{
    
    //Numero ganador
    
    function probarSuerte(uint _numero) public pure returns(bool){
        
        bool ganador;
        if(_numero == 100){
            ganador = true;
        }else{
            ganador = false;
        }
        
        return ganador;
        
    }
    
    //Calcula el valor absoluto de un Numero
    function valorAbsoluto(int _numero) public pure returns (uint){
        
        uint valor_absoluto_numero;
        if(_numero < 0){
            valor_absoluto_numero = uint(-_numero);
        }else{
            valor_absoluto_numero = uint(_numero);
        }
        
        return valor_absoluto_numero;
    }
    
    //Devolveremos true si el numero introducido es par y tiene tres cifras
    function parTresCifras(uint _numero) public pure returns(bool){
        bool flag = false;
        
        if( _numero%2 == 0 && _numero >=100 && _numero < 1000){
            flag = true;
        }
        
        return flag;
    }
    
    //votacion
    //Solo hay tres candidatos: Joan, Gabriel y Maria
    function votar(string memory _candidato) public pure returns(string memory){
        
        string memory mensaje;
        
        if(keccak256(abi.encodePacked(_candidato)) == keccak256(abi.encodePacked("Joan"))){
            mensaje = "Has votado a Joan";
        }else if(keccak256(abi.encodePacked(_candidato)) == keccak256(abi.encodePacked("Gabriel"))){
            mensaje = "Has votado a Gabriel";
        }else if(keccak256(abi.encodePacked(_candidato)) == keccak256(abi.encodePacked("Maria"))){
            mensaje = "Has votado a Maria";
        }else{
            mensaje = "Has votado mal";
        }
        
        return mensaje;
    }
    
    
}













