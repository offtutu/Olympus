import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço responsável por persistir e recuperar informações sensíveis do dispositivo
/// de forma criptografada e segura, tais como o token JWT de autenticação.
class ServicoArmazenamento {
  final FlutterSecureStorage _storage;

  ServicoArmazenamento({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _chaveToken = 'jwt_token_auth';

  /// Salva o token JWT de forma segura no dispositivo
  Future<void> salvarToken(String token) async {
    await _storage.write(key: _chaveToken, value: token);
  }

  /// Recupera o token JWT persistido
  Future<String?> obterToken() async {
    return await _storage.read(key: _chaveToken);
  }

  /// Remove o token JWT, usado principalmente para a função de logout
  Future<void> removerToken() async {
    await _storage.delete(key: _chaveToken);
  }

  /// Verifica se existe um token salvo
  Future<bool> contemToken() async {
    final token = await obterToken();
    return token != null && token.isNotEmpty;
  }
}
