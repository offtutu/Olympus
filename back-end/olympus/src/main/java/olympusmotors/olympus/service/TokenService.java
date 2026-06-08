package olympusmotors.olympus.service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;

import olympusmotors.olympus.modules.Usuario;

@Service // Aqui seta que esse pacote é 
public class TokenService {

    // Aqui vai o value da variavel de ambiente do jwt secret
    @Value("${api.security.token.secret}")
    private String segredo;

    // Aqui é um sistema para gerar os tokens(Os famosos crachas vip, como ditos anteriormente.)
    public String gerarToken(Usuario usuario) {
        // Aqui é basicamente o mesma coisa do python, onde é uma abertura de chave para tratamento de erro e retorna um catch que no python seria o ExceptionError
        try {
            // Esse aqui é o algoritmo utilizado para gerar os tokens e também eles recebem por padrão uma secret, que torna o algoritmo unico para essa API, para melhorar a segurança da criptografia e etc... Ela funciona como a chave para nosso cadeado que seria a criptografia.
            Algorithm algoritmo = Algorithm.HMAC256(segredo);
            // Aqui é comando de geração de token
            String token = JWT.create()
                    .withIssuer("olympus-api")
                    .withSubject(usuario.getLogin())
                    .withExpiresAt(gerarDataExpiracao())
                    .sign(algoritmo);
            return token;
            // Aqui retorna uma exceção, caso de erro a geração de token
        } catch (JWTCreationException exception) {
            throw new RuntimeException("Erro ao gerar token", exception);
        }
    }

    // Aqui é o sistema de validação do token
    public String validarToken(String token) {
        try {
            // Aqui coloca novamente o algoritmo utilizado na geração de tokens
            Algorithm algoritmo = Algorithm.HMAC256(segredo);
            // Aqui já retorna um require com o algoritmo como parametro, onde roda toda a validação do token gerado pelo gerarToken
            return JWT.require(algoritmo)
                    .withIssuer("olympus-api")
                    .build()
                    .verify(token)
                    .getSubject();
        // Aqui retorna uma excpetion vazia, no caso de vir um token que não foi gerado pelo gerarToken ou um expirada. Ela é vazia porque retorna já usuario não autorizado.
        } catch (JWTVerificationException exception) {
            return "";
        }
    }

    // Aqui é o sistema de geração de tempo de expiração do token, onde ele tem 2 horas de duração e é configurado para rodar o tempo no UTC -3 que é o fuso horario do brasil.
    private Instant gerarDataExpiracao() {
        return LocalDateTime.now().plusHours(2).toInstant(ZoneOffset.of("-03:00"));
    }
}
