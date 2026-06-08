package olympusmotors.olympus.modules;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// Aqui é um conexão do back e do banco de dados e cuida da transição de dados, diferente do repositorio de usuario, esse daqui cuida do banco de dados dos carros.
@Repository
public interface CarroRepository extends JpaRepository<Carro, Long> {
    Optional<Carro> findByCodigo(Integer codigo);
}
