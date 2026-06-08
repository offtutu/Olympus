package olympusmotors.olympus.config;

import java.io.IOException;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import olympusmotors.olympus.modules.UsuarioRepository;
import olympusmotors.olympus.service.TokenService;

@Component // Aqui avisa que esse é o componente da API
@RequiredArgsConstructor
// Aqui é uma classe que herda uma classa chamda OncePerRequestFilter, resumindo, é um filter que acontece a cada requisição.
public class SecurityFilter extends OncePerRequestFilter {

    // aqui são os injects nescessarios para esse componente 
    private final TokenService tokenService;
    private final UsuarioRepository usuarioRepository;

    @Override
    // Esse filtro intercepta todas as requisições HTTP que chegam ao servidor, onde analisa para ver se o usuario está permitido para mexer na API
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        // Aqui tem um meotodo para poder recuperar o token, para ele buscar no JWT dentro do authorization da requisição http
        String token = this.recuperarToken(request);
        // Aqui tem uma tomada de decisão, onde se o token for diferente de vazio, ele tenta executar o login e tenta validar o token
        if (token != null) {
            String login = tokenService.validarToken(token);
            // Apoś validar o token, garante que o login não está vazio, procurando lá no repositorio de usuario
            if (!login.isEmpty()) {
                UserDetails usuario = usuarioRepository.findByLogin(login);
                // Após extrair totalmente o login, ele procura no banco de dados o usuario por completo e checa se realmente existe esse usuario no banco
                if (usuario != null) {
                    // Após encontrar o usuario dentro do banco, gera um objeto para o spring contendo todas informações e permissões do usuario e logo manda o objeto para o spring, avisando que o usuario está autenticado e com o acesso liberado na requisição.
                    var autenticacao = new UsernamePasswordAuthenticationToken(usuario, null, usuario.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(autenticacao);
                }
            }
        }
        // Aqui é uma pausa na requisição, se o usuario foi autenticado ou se ele não tinha o token, passa para o proximo filtro ou vai pro controller
        filterChain.doFilter(request, response);
    }
    // Aqui foi o meotodo recuperar token que foi usado anteriormente no filtro,  ele é usado para extrair e limpar o token inserido pelo cliente
    private String recuperarToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return null;
        }
        return authHeader.replace("Bearer ", "");
    }
}
