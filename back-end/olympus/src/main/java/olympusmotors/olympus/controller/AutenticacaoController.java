package olympusmotors.olympus.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import olympusmotors.olympus.DTos.AutenticacaoDTO;
import olympusmotors.olympus.DTos.LoginRespostaDTO;
import olympusmotors.olympus.DTos.RegistroDTO;
import olympusmotors.olympus.modules.Usuario;
import olympusmotors.olympus.modules.UsuarioRepository;
import olympusmotors.olympus.service.TokenService;

// Aqui são as anotações que foramutilizadas para ajudar no projeto
@RestController // Aqui ele define que esse codigo é um RestController e faz parte da camada controller
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AutenticacaoController {

    // Aqui são os imports de outros pacotes que são utilizados para esse controller
    private final AuthenticationManager authenticationManager;
    private final UsuarioRepository repository;
    private final TokenService tokenService;
    private final PasswordEncoder passwordEncoder;

    // Aqui é um endpoint que utiliza o metodo http do tipo POST, onde ela tem  sistema de login, onde o usuario entrega as credenciais para o AutenticacaoDTO,  o auth entrega para o Authmanager, esse auth confere se a senha tá igual a que está no banco de dados, se o auth ver que a senha está correta, ele gera um token que seria uma especie de crachá vip para o usuario ter acesso.
    @PostMapping("/login")
    public ResponseEntity<LoginRespostaDTO> login(@RequestBody AutenticacaoDTO dados) {
        var usernamePassword = new UsernamePasswordAuthenticationToken(dados.login(), dados.senha());
        var auth = this.authenticationManager.authenticate(usernamePassword);

        // Aqui faz a geração do tokin para poder fazer o login
        var token = tokenService.gerarToken((Usuario) auth.getPrincipal());

        return ResponseEntity.ok(new LoginRespostaDTO(token));
    }

    //  Esse aqui é outro endpoint que utiliza o metodo POST, onde a função dele é o sistema de registro, o usuario manda as informações para se registrar no site, ai o sistema procura no repository se tem algum usuario com esse nome de usuario, se o repository dizer que sim, o cadastro é barrado e retorna uma erro, se dizer que não, então o cadastro é confirmado, a senha que foi usada no cadastro é criptografada e é salvo junto com o novo nome de usuario.
    @PostMapping("/registrar")
    public ResponseEntity<Void> registrar(@RequestBody RegistroDTO dados) {
        if (this.repository.findByLogin(dados.login()) != null) {
            return ResponseEntity.badRequest().build();
        }

        // Aqui faz a criptografia das senhas e já cria um novo objeto de usuario com a senha devidamente protegida.
        String senhaCriptografada = passwordEncoder.encode(dados.senha());
        Usuario novoUsuario = new Usuario(dados.login(), senhaCriptografada, dados.cargo());

        this.repository.save(novoUsuario);

        return ResponseEntity.ok().build();
    }
}
