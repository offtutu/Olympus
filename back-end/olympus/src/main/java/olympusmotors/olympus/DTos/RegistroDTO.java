package olympusmotors.olympus.DTos;

import olympusmotors.olympus.modules.UsuarioRole;

public record RegistroDTO(String login, String senha, UsuarioRole cargo) {
}
