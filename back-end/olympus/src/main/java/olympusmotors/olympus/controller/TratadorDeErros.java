package olympusmotors.olympus.controller;

import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.servlet.http.HttpServletRequest;
import olympusmotors.olympus.service.exceptions.CarroDuplicado;
import olympusmotors.olympus.service.exceptions.CarroNaoEncontrado;
import olympusmotors.olympus.service.exceptions.CodigoNaoEncontrado;
import olympusmotors.olympus.service.exceptions.Validacao;
import olympusmotors.olympus.exception.RespostaDosErros;

// Essa anotação define que o tratador de erros vai cuidar das exceções de uma forma geral para o controller e transformar em json
@RestControllerAdvice
// Essa classe  basicamente faz o controle das regras de exceções e rediciona para o HTTP mais propicio para a exceção
public class TratadorDeErros {

     // Aqui Vai ser como se  fosse um tradutor das exceções, só que esse é para erros como o 404 not found, onde ele vai pegar as regras de exceção que focam nessa parte do 404 e traduzir para o http.
    @ExceptionHandler({ CarroNaoEncontrado.class, CodigoNaoEncontrado.class })
    public ResponseEntity<RespostaDosErros> tratarNaoEncontrado(RuntimeException exception, HttpServletRequest request) {
        return montarResposta(HttpStatus.NOT_FOUND, exception, request);
    }

    // Esse aqui é a mesma coisa, só que de vez de tratar a exceções que trabalham com o erro 404, esse trabalha com o erro 400 bad request.
    @ExceptionHandler({ Validacao.class, CarroDuplicado.class })
    public ResponseEntity<RespostaDosErros> tratarRequisicaoInvalida(RuntimeException exception, HttpServletRequest request) {
        return montarResposta(HttpStatus.BAD_REQUEST, exception, request);
    }

// Aqui já é outro tradutor, só que agora para o front-end, entre as exceções do back e as respostas http em json para o front.
    private ResponseEntity<RespostaDosErros> montarResposta(HttpStatus status, RuntimeException exception, HttpServletRequest request) {
        RespostaDosErros erro = new RespostaDosErros( exception.getMessage(), status.value(), LocalDateTime.now(), request.getRequestURI());
        return ResponseEntity.status(status).body(erro);
    }
}
