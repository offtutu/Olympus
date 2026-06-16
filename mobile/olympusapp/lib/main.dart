import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/localizador_servicos.dart';
import 'core/servicos/servico_armazenamento.dart';
import 'presentation/login/login_screen.dart';
import 'presentation/login/login_viewmodel.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/dashboard/dashboard_viewmodel.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/carro_repository.dart';

void main() async {
  // Garante a inicialização das bindings de plataforma antes de rodar o app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o contêiner de Injeção de Dependências (GetIt)
  await inicializarDependencias();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Criação e fornecimento da LoginViewModel com suas dependências injetadas
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            localizador<AuthRepository>(),
            localizador<ServicoArmazenamento>(),
          ),
        ),
        // Criação e fornecimento da DashboardViewModel com suas dependências injetadas
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            localizador<CarroRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Olympus Motors',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFF8C00),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF8C00),
            secondary: Color(0xFFFF8C00),
            surface: Color(0xFF1B1B22),
          ),
        ),
        home: const FluxoInicial(),
      ),
    );
  }
}

/// Componente que decide se redireciona o usuário diretamente
/// para o Dashboard (sessão ativa) ou para a tela de Login.
class FluxoInicial extends StatelessWidget {
  const FluxoInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final servicoArmazenamento = localizador<ServicoArmazenamento>();

    return FutureBuilder<bool>(
      future: servicoArmazenamento.contemToken(),
      builder: (context, snapshot) {
        // Exibe um carregamento premium enquanto verifica o token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F12),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
              ),
            ),
          );
        }

        // Se encontrou token válido salvo localmente, vai para a Dashboard
        if (snapshot.data == true) {
          return const DashboardScreen();
        }

        // Senão, encaminha para a tela de Login
        return const LoginScreen();
      },
    );
  }
}
