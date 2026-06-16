import '../models/auth_dto.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/constantes/endpoints.dart';

/// Interface abstrata para definir as operações de Autenticação
abstract class AuthRepository {
  /// Realiza o login enviando as credenciais para o backend
  Future<LoginRespostaDto> login(AutenticacaoDto dados);

  /// Registra um novo usuário no sistema
  Future<void> registrar(RegistroDto dados);
}

/// Implementação concreta do repositório utilizando o ClienteApi
class AuthRepositoryImpl implements AuthRepository {
  final ClienteApi _clienteApi;

  AuthRepositoryImpl(this._clienteApi);

  @override
  Future<LoginRespostaDto> login(AutenticacaoDto dados) async {
    try {
      final resposta = await _clienteApi.dio.post(
        Endpoints.login,
        data: dados.toJson(),
      );
      
      // Retorna a resposta convertida em DTO
      return LoginRespostaDto.fromJson(resposta.data);
    } catch (e) {
      // Repassa o erro já tratado pelo ClienteApi
      rethrow;
    }
  }

  @override
  Future<void> registrar(RegistroDto dados) async {
    try {
      await _clienteApi.dio.post(
        Endpoints.registrar,
        data: dados.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
