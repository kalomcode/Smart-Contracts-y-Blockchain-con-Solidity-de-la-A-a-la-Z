pragma solidity >=0.4.4 <0.7.0;

contract bucle_for{
    
    //Suma de los 100 primeros numeros a partir del numero introducido
    function Suma(uint _numero) public pure returns(uint){
        
        uint suma = 0;
        
        for(uint i = _numero; i < (_numero + 100); i++){
            suma = suma + i;
        }
        
        return suma;
    }
    
    //Recorer un array
    address[] direcciones;
    
    function asociar() public{
        direcciones.push(msg.sender);
    }
    
    function comprobarAsociacion() public view returns(bool, address){
        
        for(uint i = 0; i < direcciones.length; i++){
            if(msg.sender == direcciones[i]){
                return (true, direcciones[i]);
            }
        }
        return (false, msg.sender);
    }
    
    //Doble for: Suma los 10 primeros factoriales
    //n! = n*(n-1)*(n-2)*...*2*1
    
    function sumaFactorial() public pure returns(uint){
        
        uint suma = 0;
        for( uint i = 1; i <= 10; i++ ){
            
            uint factorial = 1;
            
            for(uint j = 2; j <= i; j++){
                factorial *= j;
            }
            
            suma += factorial;
        }
        
        return suma;
    }
}










