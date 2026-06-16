import 'package:get_it/get_it.dart';
import '../core/servicos/servico_armazenamento.dart';
import '../core/rede/cliente_api.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/carro_repository.dart';

/// Instância do localizador de serviços (GetIt) para acesso global
final localizador = GetIt.instance;

/// Função encarregada de registrar todas as dependências e serviços do app
Future<void> inicializarDependencias() async {
  // Registrar o Serviço de Armazenamento Seguro
  localizador.registerLazySingleton<ServicoArmazenamento>(
    () => ServicoArmazenamento(),
  );

  // Registrar o Cliente HTTP com a injeção do ServicoArmazenamento
  localizador.registerLazySingleton<ClienteApi>(
    () => ClienteApi(localizador<ServicoArmazenamento>()),
  );

  // Registrar o Repositório de Autenticação
  localizador.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localizador<ClienteApi>()),
  );

  // Registrar o Repositório de Carros
  localizador.registerLazySingleton<CarroRepository>(
    () => CarroRepositoryImpl(localizador<ClienteApi>()),
  );
}
