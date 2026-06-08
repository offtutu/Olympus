package olympusmotors.olympus.service.exceptions;


// Aqui temos uma das regras de exceções do pacote, onde se estiver algum carro com o mesmo codigo, será considerado um carro duplicado e vai retornar um erro.
public class CarroDuplicado extends RuntimeException {
    public CarroDuplicado(Integer codigo) {
        super("O Carro com esse Codigo: " + codigo + " já existe, por favor coloque outro codigo.");
    }
}
