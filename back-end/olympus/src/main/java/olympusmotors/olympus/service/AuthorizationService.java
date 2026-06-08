package olympusmotors.olympus.service;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import olympusmotors.olympus.modules.UsuarioRepository;

// Aqui são anotações que ajudam no desenvolvimento.
@Service // Aqui avisa que esse codigo é um service e é da camada service.
@RequiredArgsConstructor
public class AuthorizationService implements UserDetailsService {

    private final UsuarioRepository repository;
    
    // Aqui é uma verificação, para quando o usuario for logar, esse carinha aqui vai pedir para o repository, o repository puxa no banco de dados o nome usuario, se ele não encontrar no banco ele passa o resultado da busca para o AuthorizationService e o AuthService retorna um erro para o usuario.
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserDetails user = repository.findByLogin(username);
        if (user == null) {
            throw new UsernameNotFoundException("Usuário não encontrado: " + username);
        }
        return user;
    }
}
