// Constantes contendo os caminhos dos endpoints da API REST
class Endpoints {
  // 10.0.2.2 é o IP padrão utilizado pelo emulador do Android para acessar o localhost da máquina hospedeira
  // Para iOS ou dispositivos físicos, altere para o IP local da sua máquina na mesma rede Wi-Fi.
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  static const String login = '/api/auth/login';
  static const String registrar = '/api/auth/registrar';
  static const String carros = '/api/carros';
}
