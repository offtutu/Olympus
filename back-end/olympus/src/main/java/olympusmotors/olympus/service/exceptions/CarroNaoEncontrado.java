package olympusmotors.olympus.service.exceptions;


// Aqui é uma das regras de exceções do projeto, onde ele retorna um erro que mostra "Carro não encontrado"  quando o id não é encontrado. o RuntimeException é como se fosse a classe herdada do ExceptionError no Python.
public class CarroNaoEncontrado extends RuntimeException {

    public CarroNaoEncontrado(Long id) {
        super("O carro com o ID: " + id + " não foi encontrado no momento.");
    }
}
