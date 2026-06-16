/// DTO (Data Transfer Object) para requisição de login
class AutenticacaoDto {
  final String login;
  final String senha;

  AutenticacaoDto({
    required this.login,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'senha': senha,
    };
  }
}

/// DTO contendo o token retornado pela API após autenticação bem-sucedida
class LoginRespostaDto {
  final String token;

  LoginRespostaDto({
    required this.token,
  });

  factory LoginRespostaDto.fromJson(Map<String, dynamic> json) {
    return LoginRespostaDto(
      token: json['token'] ?? '',
    );
  }
}

/// DTO para criação de uma nova conta de usuário
class RegistroDto {
  final String login;
  final String senha;
  final String cargo; // Pode ser "ADMIN" ou "COMUM"

  RegistroDto({
    required this.login,
    required this.senha,
    required this.cargo,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'senha': senha,
      'cargo': cargo,
    };
  }
}
