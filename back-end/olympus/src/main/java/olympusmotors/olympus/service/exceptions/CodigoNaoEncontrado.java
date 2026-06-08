package olympusmotors.olympus.service.exceptions;


// Aqui é uma das regras de exceções do projeto, onde ele retorna um erro que mostra "Carro não encontrado"  quando o codigo inserido não é encontrado.
public class CodigoNaoEncontrado extends RuntimeException {
        public CodigoNaoEncontrado(Integer codigo) {
        super("O carro com o codigo: " + codigo + " não foi encontrado no momento.");
    }
}
