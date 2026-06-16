import 'package:dio/dio.dart';
import '../constantes/endpoints.dart';
import '../servicos/servico_armazenamento.dart';

/// Cliente HTTP customizado construído sobre o pacote Dio.
/// Centraliza a configuração de URL base, timeouts, inclusão automática
/// do cabeçalho Bearer Token e o tratamento global de códigos HTTP de erro comuns.
class ClienteApi {
  final Dio _dio;
  final ServicoArmazenamento _servicoArmazenamento;

  ClienteApi(this._servicoArmazenamento) : _dio = Dio() {
    // Configurações básicas da instância do Dio
    _dio.options.baseUrl = Endpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Adiciona os interceptores para requisições e erros
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Busca o token salvo e injeta no header Authorization de cada chamada
        final token = await _servicoArmazenamento.obterToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Executa o tratamento e lança exceções mais amigáveis e estruturadas
        final excecaoTratada = _tratarErro(e);
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: excecaoTratada,
          message: excecaoTratada.mensagem,
        ));
      },
    ));
  }

  /// Expõe a instância do Dio para requisições diretas se necessário
  Dio get dio => _dio;

  /// Método privado encarregado de ler o erro do Dio e envelopar em classes tipadas
  ExcecaoApi _tratarErro(DioException e) {
    if (e.response != null) {
      final status = e.response?.statusCode;
      final dadosResposta = e.response?.data;
      
      String obterMensagemErro() {
        if (dadosResposta is Map) {
          return dadosResposta['mensagem'] ?? dadosResposta['message'] ?? 'Erro inesperado da API.';
        }
        return 'Erro inesperado da API.';
      }

      switch (status) {
        case 401:
          // Caso a credencial esteja errada ou o token expire/seja inválido, limpa localmente
          _servicoArmazenamento.removerToken();
          return ExcecaoAutenticacao('Sessão expirada ou credenciais inválidas. Faça login novamente.');
        case 403:
          return ExcecaoAcessoNegado('Acesso negado. Você não tem permissão para acessar este recurso.');
        case 500:
          return ExcecaoServidor('Erro interno do servidor. Entre em contato com o administrador.');
        default:
          return ExcecaoApi(obterMensagemErro(), status: status);
      }
    } else {
      // Erro sem resposta do servidor (ex: fora da rede, timeout)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ExcecaoRede('Tempo de requisição esgotado. Verifique sua conexão de internet.');
      }
      return ExcecaoRede('Não foi possível se conectar ao servidor. Verifique se a API está online.');
    }
  }
}

/// Exceção genérica para erros ocorridos na comunicação com a API
class ExcecaoApi implements Exception {
  final String mensagem;
  final int? status;

  ExcecaoApi(this.mensagem, {this.status});

  @override
  String toString() => mensagem;
}

/// Exceção específica para erros de autenticação (HTTP 401)
class ExcecaoAutenticacao extends ExcecaoApi {
  ExcecaoAutenticacao(super.mensagem);
}

/// Exceção específica para recursos negados (HTTP 403)
class ExcecaoAcessoNegado extends ExcecaoApi {
  ExcecaoAcessoNegado(super.mensagem);
}

/// Exceção específica para erros internos do backend (HTTP 500)
class ExcecaoServidor extends ExcecaoApi {
  ExcecaoServidor(super.mensagem);
}

/// Exceção de rede ou de conexão offline
class ExcecaoRede extends ExcecaoApi {
  ExcecaoRede(super.mensagem);
}
