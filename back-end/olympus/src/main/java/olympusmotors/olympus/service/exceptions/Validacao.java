package olympusmotors.olympus.service.exceptions;


// Aqui é outra das regras de exceções do projeto, onde é a parte da validação, onde retorna um erro especifico tipo carecteres invalidos e etc...
public class Validacao extends RuntimeException {
    public Validacao(String campo, String modulo) {
        super("O campo: " + campo + " é inválido pois: " + modulo);
    }
}
