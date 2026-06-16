import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_viewmodel.dart';
import '../dashboard/dashboard_screen.dart';

/// Tela de Login e Registro Olympus Motors.
/// Adapta com alta fidelidade a identidade visual premium da versão Web para Mobile.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  bool _ehModoRegistro = false;
  String _cargoSelecionado = 'COMUM';
  bool _lembrarMe = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _alternarModo(LoginViewModel viewModel) {
    setState(() {
      _ehModoRegistro = !_ehModoRegistro;
      _formKey.currentState?.reset();
      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
      _confirmarSenhaController.clear();
      viewModel.limparErros();
    });
  }

  Future<void> _submeter(LoginViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (_ehModoRegistro) {
      if (senha != _confirmarSenhaController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('As senhas não coincidem!'),
            backgroundColor: Color(0xFFFF3E56),
          ),
        );
        return;
      }
      final sucesso = await viewModel.registrarUsuario(email, senha, _cargoSelecionado);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Acesse o painel.'),
            backgroundColor: Colors.green,
          ),
        );
        _alternarModo(viewModel);
      }
    } else {
      final sucesso = await viewModel.fazerLogin(email, senha);
      if (sucesso && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    // Paleta de Cores Olympus Motors (Fidelidade Web)
    const corFundo = Color(0xFF0A0B0E);
    const corCard = Color(0xFF13151A);
    const corBorda = Color(0xFF1E2128);
    const corPrimaria = Color(0xFFFF3E56); // Vermelho Olympus
    const corTextoPrincipal = Color(0xFFF3F4F6);
    const corTextoMuted = Color(0xFF8C92AC);

    final isTablet = MediaQuery.of(context).size.width > 760;

    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: isTablet
            ? Row(
                children: [
                  Expanded(child: _construirBannerCarro(corCard, corPrimaria, corTextoPrincipal, corTextoMuted)),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: _construirFormulario(viewModel, corCard, corBorda, corPrimaria, corTextoPrincipal, corTextoMuted),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo
                    _construirHeaderLogo(corTextoPrincipal),
                    const SizedBox(height: 20),
                    
                    // Banner do Carro / Imagem
                    _construirBannerCarro(corCard, corPrimaria, corTextoPrincipal, corTextoMuted),
                    const SizedBox(height: 24),
                    
                    // Formulario de login/cadastro
                    _construirFormulario(viewModel, corCard, corBorda, corPrimaria, corTextoPrincipal, corTextoMuted),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _construirHeaderLogo(Color corTextoPrincipal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/olympuslogo.png',
          height: 38,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.directions_car_rounded,
            color: Color(0xFFFF3E56),
            size: 32,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'OLYMPUS MOTORS',
          style: TextStyle(
            color: corTextoPrincipal,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _construirBannerCarro(Color corCard, Color corPrimaria, Color corTextoPrincipal, Color corTextoMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2128), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagem do veículo central
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 13,
              child: Image.asset(
                'assets/images/OlympusMotors.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 50),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bullet 1
          _construirBullet(
            'Performance',
            'Veículos de alta performance',
            corPrimaria,
            corTextoPrincipal,
            corTextoMuted,
          ),
          const SizedBox(height: 12),
          // Bullet 2
          _construirBullet(
            'Exclusividade',
            'Só aqui você encontra os melhores carros e com os melhores preços',
            corPrimaria,
            corTextoPrincipal,
            corTextoMuted,
          ),
          const SizedBox(height: 12),
          // Bullet 3
          _construirBullet(
            'Segurança',
            'Dados protegidos e criptografados',
            corPrimaria,
            corTextoPrincipal,
            corTextoMuted,
          ),
        ],
      ),
    );
  }

  Widget _construirBullet(
    String titulo,
    String descricao,
    Color corPrimaria,
    Color corTextoPrincipal,
    Color corTextoMuted,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            Icons.chevron_right_rounded,
            color: corPrimaria,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, fontFamily: 'Roboto', color: corTextoMuted),
              children: [
                TextSpan(
                  text: '$titulo — ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: corTextoPrincipal),
                ),
                TextSpan(text: descricao),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirFormulario(
    LoginViewModel viewModel,
    Color corCard,
    Color corBorda,
    Color corPrimaria,
    Color corTextoPrincipal,
    Color corTextoMuted,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Conexão Status Pills


          // Seção de Cabeçalho do Acesso
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 16,
                color: corPrimaria,
              ),
              const SizedBox(width: 8),
              Text(
                _ehModoRegistro ? 'NOVO PILOTO' : 'ACESSO RESTRITO',
                style: TextStyle(
                  color: corPrimaria,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _ehModoRegistro ? 'Criar sua conta' : 'Entre na sua conta',
            style: TextStyle(
              color: corTextoPrincipal,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _ehModoRegistro ? 'Junte-se à frota exclusiva Olympus Motors' : 'Acesse o painel exclusivo Olympus Motors',
            style: TextStyle(
              color: corTextoMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),

          // Nome Completo (Apenas Registro)
          if (_ehModoRegistro) ...[
            _construirInputLabel('NOME COMPLETO', corTextoMuted),
            const SizedBox(height: 6),
            _construirCampoTexto(
              controller: _nomeController,
              hint: 'Seu nome completo',
              icone: Icons.person_outline,
              corBorda: corBorda,
              corTexto: corTextoPrincipal,
              corMuted: corTextoMuted,
              validador: (val) => val == null || val.trim().isEmpty ? 'Digite seu nome completo' : null,
            ),
            const SizedBox(height: 20),
          ],

          // E-mail / Usuário
          _construirInputLabel('E-MAIL', corTextoMuted),
          const SizedBox(height: 6),
          _construirCampoTexto(
            controller: _emailController,
            hint: 'seu@email.com',
            icone: Icons.mail_outline,
            corBorda: corBorda,
            corTexto: corTextoPrincipal,
            corMuted: corTextoMuted,
            validador: (val) {
              if (val == null || val.trim().isEmpty) return 'Digite seu e-mail';
              if (!val.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Senha
          _construirInputLabel('SENHA', corTextoMuted),
          const SizedBox(height: 6),
          _construirCampoTexto(
            controller: _senhaController,
            hint: '••••••••',
            icone: Icons.lock_outline,
            obscure: true,
            corBorda: corBorda,
            corTexto: corTextoPrincipal,
            corMuted: corTextoMuted,
            validador: (val) => val == null || val.trim().isEmpty ? 'Digite sua senha' : null,
          ),
          const SizedBox(height: 20),

          // Confirmar Senha (Apenas Registro)
          if (_ehModoRegistro) ...[
            _construirInputLabel('CONFIRMAR SENHA', corTextoMuted),
            const SizedBox(height: 6),
            _construirCampoTexto(
              controller: _confirmarSenhaController,
              hint: '••••••••',
              icone: Icons.lock_outline,
              obscure: true,
              corBorda: corBorda,
              corTexto: corTextoPrincipal,
              corMuted: corTextoMuted,
              validador: (val) => val == null || val.trim().isEmpty ? 'Confirme sua senha' : null,
            ),
            const SizedBox(height: 20),

            // Cargo do Usuário Dropdown
            _construirInputLabel('CARGO DO USUÁRIO', corTextoMuted),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF101115),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: corBorda),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _cargoSelecionado,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF13151A),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: corTextoMuted),
                  style: TextStyle(color: corTextoPrincipal, fontSize: 14),
                  items: const [
                    DropdownMenuItem(
                      value: 'COMUM',
                      child: Text('COMUM (Apenas Visualizar Carros)'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN',
                      child: Text('ADMIN (Acesso Total)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _cargoSelecionado = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Lembrar-me & Esqueci a senha (Apenas Login)
          if (!_ehModoRegistro) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _lembrarMe,
                        activeColor: corPrimaria,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3E4253)),
                        onChanged: (val) {
                          if (val != null) setState(() => _lembrarMe = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lembrar-me',
                      style: TextStyle(color: corTextoMuted, fontSize: 13),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text(
                    'Esqueci a senha',
                    style: TextStyle(color: Color(0xFFFF5266), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Exibição de Mensagem de Erro Centralizada
          if (viewModel.mensagemErro != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: corPrimaria.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: corPrimaria.withOpacity(0.3)),
              ),
              child: Text(
                viewModel.mensagemErro!,
                style: TextStyle(color: corPrimaria, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Botão Principal Acessar / Cadastrar
          ElevatedButton(
            onPressed: viewModel.carregando ? null : () => _submeter(viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: corPrimaria,
              foregroundColor: Colors.white,
              disabledBackgroundColor: corPrimaria.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            child: viewModel.carregando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _ehModoRegistro ? 'CRIAR CONTA' : 'ACESSAR',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // Alternar Modo de Registro / Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _ehModoRegistro ? 'Já tem uma conta? ' : 'Não tem uma conta? ',
                style: TextStyle(color: corTextoMuted, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => _alternarModo(viewModel),
                child: Text(
                  _ehModoRegistro ? 'Entrar' : 'Criar conta',
                  style: const TextStyle(
                    color: Color(0xFFFF5266),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirInputLabel(String labelText, Color corTextoMuted) {
    return Text(
      labelText,
      style: TextStyle(
        color: corTextoMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _construirCampoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    bool obscure = false,
    required Color corBorda,
    required Color corTexto,
    required Color corMuted,
    String? Function(String?)? validador,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: corTexto, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: corMuted.withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(icone, color: corMuted, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: const Color(0xFF101115),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: corBorda, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF3E56), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: validador,
    );
  }
}
