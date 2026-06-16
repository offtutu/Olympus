import 'package:flutter/material.dart';
import '../../../data/models/carro_dto.dart';
import '../../../data/repositories/carro_repository.dart';

/// ViewModel que gerencia a lógica de negócio e o estado da tela de Dashboard.
class DashboardViewModel extends ChangeNotifier {
  final CarroRepository _carroRepository;

  DashboardViewModel(this._carroRepository);

  List<CarroDto> _carros = [];
  List<CarroDto> get carros => _carros;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  void _definirCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  void _definirMensagemErro(String? valor) {
    _mensagemErro = valor;
    notifyListeners();
  }

  /// Carrega a lista completa de carros do servidor
  Future<void> carregarCarros() async {
    _definirCarregando(true);
    _definirMensagemErro(null);

    try {
      _carros = await _carroRepository.listarCarros();
      _definirCarregando(false);
    } catch (e) {
      _definirCarregando(false);
      _definirMensagemErro(e.toString());
    }
  }

  /// Remove um carro do sistema e atualiza a interface localmente
  Future<bool> deletarCarro(int id) async {
    _definirMensagemErro(null);
    try {
      await _carroRepository.deletarCarro(id);
      _carros.removeWhere((carro) => carro.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _definirMensagemErro(e.toString());
      return false;
    }
  }

  /// Adiciona um novo carro
  Future<bool> cadastrarCarro(int codigo, String nome, String marca, String modelo, int ano) async {
    _definirCarregando(true);
    _definirMensagemErro(null);
    try {
      final dados = {
        'codigo': codigo,
        'nome': nome,
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
      };
      
      final novoCarro = await _carroRepository.criarCarro(dados);
      _carros.add(novoCarro);
      _definirCarregando(false);
      return true;
    } catch (e) {
      _definirCarregando(false);
      _definirMensagemErro(e.toString());
      return false;
    }
  }

  /// Limpa os erros armazenados no ViewModel
  void limparErros() {
    _definirMensagemErro(null);
  }
}
