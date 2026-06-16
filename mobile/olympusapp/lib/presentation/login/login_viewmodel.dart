import 'package:flutter/material.dart';
import '../../../data/models/auth_dto.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/servicos/servico_armazenamento.dart';

/// ViewModel que gerencia o estado da tela de autenticação (Login e Registro).
/// Utiliza ChangeNotifier para notificar a View sobre alterações no estado.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ServicoArmazenamento _servicoArmazenamento;

  LoginViewModel(this._authRepository, this._servicoArmazenamento);

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  /// Controla o estado de carregamento da tela
  void _definirCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  /// Define a mensagem de erro a ser exibida para o usuário
  void _definirMensagemErro(String? valor) {
    _mensagemErro = valor;
    notifyListeners();
  }

  /// Executa o fluxo de login
  Future<bool> fazerLogin(String usuario, String senha) async {
    _definirCarregando(true);
    _definirMensagemErro(null);

    try {
      final dados = AutenticacaoDto(login: usuario, senha: senha);
      final resposta = await _authRepository.login(dados);
      
      // Salva o token JWT de forma segura no dispositivo
      await _servicoArmazenamento.salvarToken(resposta.token);
      
      _definirCarregando(false);
      return true;
    } catch (e) {
      _definirCarregando(false);
      _definirMensagemErro(e.toString());
      return false;
    }
  }

  /// Executa o fluxo de cadastro de um novo usuário
  Future<bool> registrarUsuario(String usuario, String senha, String cargo) async {
    _definirCarregando(true);
    _definirMensagemErro(null);

    try {
      final dados = RegistroDto(login: usuario, senha: senha, cargo: cargo);
      await _authRepository.registrar(dados);
      
      _definirCarregando(false);
      return true;
    } catch (e) {
      _definirCarregando(false);
      _definirMensagemErro(e.toString());
      return false;
    }
  }

  /// Limpa qualquer mensagem de erro residual
  void limparErros() {
    _definirMensagemErro(null);
  }
}
