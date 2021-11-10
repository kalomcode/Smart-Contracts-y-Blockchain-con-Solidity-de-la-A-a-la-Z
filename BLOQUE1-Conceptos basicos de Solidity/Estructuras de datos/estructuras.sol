pragma solidity >=0.4.4 <0.7.0;

contract Estructuras {
    
    //Cliente de una pagina web de pago
    struct cliente{
        uint id;
        string name;
        string dni;
        string mail;
        uint phone_number;
        uint credit_number;
        uint secret_number;
    }
    
    cliente cliente_1 = cliente(1, "kalom", "1234534G", "kalom@gmail.com", 686432894, 1234, 11);
    
    //Amazon (cualquier pagina de compra venta de productos)
    struct producto{
        string nombre;
        uint precio;
    }
    
    producto movil = movil("iphone", 1200);
    
    //Proyecto coperativo de ONGs para ayudar en diversas causas
    struct ONG{
        address ong;
        string nombre;
    }
    
    ONG Once = Once(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "Once");
    
    struct Causa{
        uint id;
        string nombre;
        uint precio_objetivo;
    }
    
    Causa medicamentos = Causa(1, "medicamentos", 1000);
    
}