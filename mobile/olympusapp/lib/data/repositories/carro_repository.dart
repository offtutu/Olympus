import '../models/carro_dto.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/constantes/endpoints.dart';

/// Interface abstrata para definir as operações de dados de Carros
abstract class CarroRepository {
  /// Lista todos os carros cadastrados no sistema
  Future<List<CarroDto>> listarCarros();

  /// Busca os detalhes de um carro por ID
  Future<CarroDto> buscarCarroPorId(int id);

  /// Cadastra um novo carro
  Future<CarroDto> criarCarro(Map<String, dynamic> dadosCarro);

  /// Atualiza as informações de um carro por ID
  Future<CarroDto> atualizarCarro(int id, Map<String, dynamic> dadosCarro);

  /// Remove um carro do sistema por ID
  Future<void> deletarCarro(int id);
}

/// Implementação concreta do repositório utilizando o ClienteApi
class CarroRepositoryImpl implements CarroRepository {
  final ClienteApi _clienteApi;

  CarroRepositoryImpl(this._clienteApi);

  @override
  Future<List<CarroDto>> listarCarros() async {
    try {
      final resposta = await _clienteApi.dio.get(Endpoints.carros);
      
      // Converte a lista dinâmica recebida da API em uma lista tipada de CarroDto
      final lista = resposta.data as List;
      return lista.map((item) => CarroDto.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CarroDto> buscarCarroPorId(int id) async {
    try {
      final resposta = await _clienteApi.dio.get('${Endpoints.carros}/$id');
      return CarroDto.fromJson(resposta.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CarroDto> criarCarro(Map<String, dynamic> dadosCarro) async {
    try {
      final resposta = await _clienteApi.dio.post(
        Endpoints.carros,
        data: dadosCarro,
      );
      return CarroDto.fromJson(resposta.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CarroDto> atualizarCarro(int id, Map<String, dynamic> dadosCarro) async {
    try {
      final resposta = await _clienteApi.dio.put(
        '${Endpoints.carros}/$id',
        data: dadosCarro,
      );
      return CarroDto.fromJson(resposta.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletarCarro(int id) async {
    try {
      await _clienteApi.dio.delete('${Endpoints.carros}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
