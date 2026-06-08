package olympusmotors.olympus.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import lombok.RequiredArgsConstructor;

@Configuration // Aqui seta que esse pacote é um config
@EnableWebSecurity // aqui é uma anotação que ativa a customização de segurança web
@RequiredArgsConstructor
public class SecurityConfigurations {

    // Aqui é o injet da dependencia pro filtro de segurança
    private final SecurityFilter securityFilter;

    @Bean
    // Aqui é o filtro de segurança e sua configuração onde ele recebe parametetro de segurança http
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
                // Aqui é a desativazação do csrf, já que a API utiliza token e não cookies
                .csrf(csrf -> csrf.disable())
                // Aqui habilita a configuração de CORS para permitir requisições do front-end
                .cors(cors -> {})
                // Esse daqui avisa que a sessao é stateless, então o servidor não vai guardar nenhum dado de sessão, cada requisição vai ter seu token
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // Aqui são as autorizações de Requests HTTP, onde tem as requests permitidas para todos os cargos e request permitidas apenas para adm.
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/auth/registrar").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/carros").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/carros/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/carros").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/carros/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/carros/**").hasRole("ADMIN")
                        .anyRequest().authenticated()
                )
                // Aqui é um sistema de adição de filtro, que seria o security filter, onde antes de autorizar as request de http, ele passa todo pelo filtro de segurança e se der algo invalido, já para o security filter chain
                .addFilterBefore(securityFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    // Aqui ela define basicamente um porteiro do sistema, quando um usuario tenta fazer login, ele valida se os dados estão corretos, buscando as informações no banco de dados e verificando as permissões de acesso.
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    // Aqui é uma configuração para criptografar senhas e melhorar a segurança do sistema, também mantendo a boa pratica de desenvolvimento. 
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
