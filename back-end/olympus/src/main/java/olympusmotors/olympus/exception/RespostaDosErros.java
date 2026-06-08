package olympusmotors.olympus.exception;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
// Essa classe basicamente é para as respostas de erros virem mais organizadas e também melhora a segurança da aplicação também
public class RespostaDosErros {
    private String mensagem;
    private int status;
    private LocalDateTime timestamp;
    private String path;
}
