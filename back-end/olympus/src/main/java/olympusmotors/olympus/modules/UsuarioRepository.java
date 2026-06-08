package olympusmotors.olympus.modules;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.security.core.userdetails.UserDetails;

// Aqui faz um conexão do back-end com o banco de dados e cuida da parte da transição, onde nesse caso, aqui faz conexão com o banco de usuarios e cuida dos dados dele.
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    UserDetails findByLogin(String login);
}
