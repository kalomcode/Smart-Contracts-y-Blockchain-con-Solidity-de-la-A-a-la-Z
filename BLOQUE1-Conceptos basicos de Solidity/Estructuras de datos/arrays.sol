pragma solidity >=0.4.4 <0.7.0;

contract Arrays {
    
    //Array de enteros de longitud fija 5
    uint[5] public array_enteros = [1,2,3,4,5];
    
    //Array de enteros de 32 bits de longitud fija con 7 posiciones
    uint32[7] array_enteros_32_bits;
    
    //Array de strings de longitud fija 15 
    string[15] arra_strings;
    
    //Array dinamico de enteros
    uint[] public array_dinamico_enteros;
    
    struct Persona {
        string nombre;
        uint edad;
    }
    
    //Array dinamico de tipo Persona
    Persona[] public array_dinamico_personas;
    
    function modificar_array(string memory _nombre, uint _edad) public {
        //array_dinamico_enteros.push(2);
        array_dinamico_personas.push(Persona(_nombre, _edad));
    }
    
    uint public test = array_enteros[2];
}