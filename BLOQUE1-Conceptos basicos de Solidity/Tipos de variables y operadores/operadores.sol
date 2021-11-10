pragma solidity >=0.4.4 <0.7.0;

contract Operadores {
    
    //Operadores matematicos
    uint a = 32;
    uint b = 4;
    
    uint public suma = a + b;
    uint public multiplicacion = a * b;
    uint public exponencial = a ** b;
    uint public residuo = a % b;
    
    //Operadores comparadores
    bool public test_1 = a > b;
    bool public test_2 = a == b;
    
    //Operadores booleanos
    
    //Criterio de divisibilidad entre 5: si el numero termina en 0 o en int56

    function divisibilidad(uint _k) public view returns(bool){
        
        uint ultima_cifra = _k % 10;

        if((ultima_cifra == 0) || (ultima_cifra == 5)){
            return true;
        }else{
            return false;
        }
    }
    
    function divisibilidadV2(uint _k) public view returns(bool){
        
        uint ultima_cifra = _k % 10;
        
        if((ultima_cifra != 0) && (ultima_cifra != 5)){
            return false;
        }else{
            return true;
        }
    }
    
}