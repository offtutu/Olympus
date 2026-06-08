package olympusmotors.olympus.modules;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


// Aqui é as anotações para faciliar o desenvolvimento
@Table(name = "usuarios") // Aqui é um link com o banco de dados usuario
@Entity(name = "Usuario") // Aqui seta que essa classe é uma entidade, onde ele pegaria os dados do banco de dados e transformaria ele em um objeto java.
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id") // Aqui é a automatização de Equals e Hash code
public class Usuario implements UserDetails {

    @Id // Aqui é um set para o banco de dados indetifcar esse dado como o ID da tabela
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String login;
    private String senha;

    @Enumerated(EnumType.STRING) // Essa daqui é uma anotação para definir como esse dado vai ser gravado no banco
    private UsuarioRole cargo;

    // Aqui é um comando para poder catalogar um usuario dentro do java
    public Usuario(String login, String senha, UsuarioRole cargo) {
        this.login = login;
        this.senha = senha;
        this.cargo = cargo;
    }

    // Aqui é uma verificação de cargo, se o seu usuario estiver com o cargo de ADM, ele tem acesso total, se não, ele é apenas um funcionario comum que tem as permissões comuns.
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (this.cargo == UsuarioRole.ADMIN) {
            return List.of(
                new SimpleGrantedAuthority("ROLE_ADMIN"),
                new SimpleGrantedAuthority("ROLE_COMUM")
            );
        }
        return List.of(new SimpleGrantedAuthority("ROLE_COMUM"));
    }

    // Aqui é um comando para pegar a senha do usuario
    @Override
    public String getPassword() {
        return this.senha;
    }

    // Aqui é um comando para pegar o login do usuario
    @Override
    public String getUsername() {
        return this.login;
    }

    // é uma autenticação para ver se a conta está expirada ou não, nesse caso ela tá retornando que a conta não está expirada.
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    // Aqui é uma autenticação para ver se não está expirada, nesse caso eela tá retornando true, então não está expirada.
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    // Aqui é uma autenticação para ver se sua credencial que no caso seria seu token, se ela não está expirada, que nesse caso ela tá retornando true, então ela não está.
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    // Aqui é autenticação para ver se a conta está habilitado, que nessa ocasião que estamos, ela retorna um true, então tá habilitada sim.
    @Override
    public boolean isEnabled() {
        return true;
    }
}
