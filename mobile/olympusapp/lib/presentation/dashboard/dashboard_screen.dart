import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_viewmodel.dart';
import '../login/login_screen.dart';
import '../../core/servicos/servico_armazenamento.dart';
import '../../di/localizador_servicos.dart';
import '../../data/models/carro_dto.dart';

/// Tela de Dashboard com alta fidelidade visual.
/// Adapta os elementos do Painel Web para a versão mobile.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pesquisaController = TextEditingController();
  String _filtroPesquisa = '';
  String _ordenacaoSelecionada = 'Ano: Recente';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().carregarCarros();
    });
    _pesquisaController.addListener(() {
      setState(() {
        _filtroPesquisa = _pesquisaController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogout() async {
    final armazenamento = localizador<ServicoArmazenamento>();
    await armazenamento.removerToken();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _abrirDialogoAdicionar(BuildContext context, DashboardViewModel viewModel) {
    final formKey = GlobalKey<FormState>();
    final codigoController = TextEditingController();
    final nomeController = TextEditingController();
    final marcaController = TextEditingController();
    final modeloController = TextEditingController();
    final anoController = TextEditingController();

    const corTextoClaro = Color(0xFFF3F4F6);
    const corTextoEsmaecido = Color(0xFF8C92AC);
    const corBorda = Color(0xFF1E2128);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13151A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.directions_car_rounded, color: Color(0xFFFF3E56)),
              SizedBox(width: 10),
              Text(
                'Cadastrar Novo Veículo',
                style: TextStyle(color: corTextoClaro, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _campoFormulario(codigoController, 'CÓDIGO', TextInputType.number, corBorda, corTextoEsmaecido, (val) {
                    if (val == null || val.isEmpty) return 'Digite o código';
                    if (int.tryParse(val) == null) return 'Deve ser um número';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _campoFormulario(nomeController, 'NOME', TextInputType.text, corBorda, corTextoEsmaecido, (val) => val == null || val.isEmpty ? 'Digite o nome' : null),
                  const SizedBox(height: 12),
                  _campoFormulario(marcaController, 'MARCA', TextInputType.text, corBorda, corTextoEsmaecido, (val) => val == null || val.isEmpty ? 'Digite a marca' : null),
                  const SizedBox(height: 12),
                  _campoFormulario(modeloController, 'MODELO', TextInputType.text, corBorda, corTextoEsmaecido, (val) => val == null || val.isEmpty ? 'Digite o modelo' : null),
                  const SizedBox(height: 12),
                  _campoFormulario(anoController, 'ANO DE FABRICAÇÃO', TextInputType.number, corBorda, corTextoEsmaecido, (val) {
                    if (val == null || val.isEmpty) return 'Digite o ano';
                    final ano = int.tryParse(val);
                    if (ano == null || ano < 1900 || ano > 2100) return 'Ano inválido';
                    return null;
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: corTextoEsmaecido, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final codigo = int.parse(codigoController.text);
                  final nome = nomeController.text.trim();
                  final marca = marcaController.text.trim();
                  final modelo = modeloController.text.trim();
                  final ano = int.parse(anoController.text);

                  final sucesso = await viewModel.cadastrarCarro(codigo, nome, marca, modelo, ano);
                  if (sucesso && context.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veículo cadastrado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3E56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('CADASTRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _campoFormulario(
    TextEditingController controller,
    String label,
    TextInputType teclado,
    Color corBorda,
    Color corTextoEsmaecido,
    String? Function(String?)? validador,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: corTextoEsmaecido, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: corBorda, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF3E56), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFF101115),
      ),
      validator: validador,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    // Paleta de Cores Olympus
    const corFundo = Color(0xFF0A0B0E);
    const corCard = Color(0xFF13151A);
    const corBorda = Color(0xFF1E2128);
    const corPrimaria = Color(0xFFFF3E56);
    const corTextoPrincipal = Color(0xFFF3F4F6);
    const corTextoMuted = Color(0xFF8C92AC);

    // Filtrar e ordenar a lista
    List<CarroDto> carrosFiltrados = viewModel.carros.where((carro) {
      final matchFiltro = carro.nome.toLowerCase().contains(_filtroPesquisa) ||
          carro.marca.toLowerCase().contains(_filtroPesquisa) ||
          carro.modelo.toLowerCase().contains(_filtroPesquisa) ||
          carro.codigo.toString().contains(_filtroPesquisa);
      return matchFiltro;
    }).toList();

    if (_ordenacaoSelecionada == 'Ano: Recente') {
      carrosFiltrados.sort((a, b) => b.ano.compareTo(a.ano));
    } else if (_ordenacaoSelecionada == 'Ano: Antigo') {
      carrosFiltrados.sort((a, b) => a.ano.compareTo(b.ano));
    } else if (_ordenacaoSelecionada == 'Nome') {
      carrosFiltrados.sort((a, b) => a.nome.compareTo(b.nome));
    }

    // Calcular métricas dinamicamente
    final totalVeiculos = viewModel.carros.length;
    final marcasRegistradas = viewModel.carros.map((c) => c.marca.toLowerCase().trim()).toSet().length;
    
    // Veículos Recentes (últimos 3 anos, ex: >= 2023)
    final anoAtual = DateTime.now().year;
    final veiculosRecentes = viewModel.carros.where((c) => c.ano >= (anoAtual - 3)).length;

    // Líder de Stock
    String liderStock = 'Nenhum';
    int liderUnidades = 0;
    final marcasContagem = <String, int>{};
    if (viewModel.carros.isNotEmpty) {
      for (var c in viewModel.carros) {
        final m = c.marca.trim();
        marcasContagem[m] = (marcasContagem[m] ?? 0) + 1;
      }
      if (marcasContagem.isNotEmpty) {
        final maiorMarca = marcasContagem.entries.reduce((a, b) => a.value > b.value ? a : b);
        liderStock = maiorMarca.key;
        liderUnidades = maiorMarca.value;
      }
    }

    // Top Marcas para o gráfico
    final marcasOrdenadas = marcasContagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMarcas = marcasOrdenadas.take(4).toList();

    // Classificação por idade
    int totalNovos = 0; // 0-2 anos
    int totalSeminovos = 0; // 3-5 anos
    int totalClassicos = 0; // 6+ anos
    for (var c in viewModel.carros) {
      final idade = anoAtual - c.ano;
      if (idade <= 2) {
        totalNovos++;
      } else if (idade <= 5) {
        totalSeminovos++;
      } else {
        totalClassicos++;
      }
    }

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corCard,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: corBorda, height: 1.5),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/olympuslogo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_rounded, color: corPrimaria),
            ),
            const SizedBox(width: 8),
            const Text(
              'PAINEL OLYMPUS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: corTextoPrincipal, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: corTextoPrincipal, size: 20),
            onPressed: viewModel.carregarCarros,
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: corPrimaria, size: 20),
            onPressed: _fazerLogout,
            tooltip: 'Sair do Sistema',
          ),
        ],
      ),
      body: viewModel.carregando && viewModel.carros.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: corPrimaria),
            )
          : RefreshIndicator(
              onRefresh: viewModel.carregarCarros,
              color: corPrimaria,
              backgroundColor: corCard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sub-Header com controle de stock
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAINEL OLYMPUS MOTORS',
                          style: TextStyle(color: corPrimaria, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Controle de Stock',
                          style: TextStyle(color: corTextoPrincipal, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Grid de Indicadores KPI (2x2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _construirKpiCard(
                          titulo: 'TOTAL DE VEÍCULOS',
                          valor: '$totalVeiculos',
                          legenda: 'Total em stock',
                          icone: Icons.directions_car_rounded,
                          corIcone: Colors.redAccent,
                          corCard: corCard,
                          corBorda: corBorda,
                          corTexto: corTextoPrincipal,
                          corMuted: corTextoMuted,
                        ),
                        _construirKpiCard(
                          titulo: 'MARCAS REGISTADAS',
                          valor: '$marcasRegistradas',
                          legenda: 'de $marcasRegistradas disponíveis',
                          icone: Icons.local_offer_rounded,
                          corIcone: Colors.amber,
                          corCard: corCard,
                          corBorda: corBorda,
                          corTexto: corTextoPrincipal,
                          corMuted: corTextoMuted,
                        ),
                        _construirKpiCard(
                          titulo: 'VEÍCULOS RECENTES',
                          valor: '$veiculosRecentes',
                          legenda: '$veiculosRecentes no total geral',
                          icone: Icons.flash_on_rounded,
                          corIcone: Colors.orange,
                          corCard: corCard,
                          corBorda: corBorda,
                          corTexto: corTextoPrincipal,
                          corMuted: corTextoMuted,
                        ),
                        _construirKpiCard(
                          titulo: 'LÍDER DE STOCK',
                          valor: liderStock,
                          legenda: '$liderUnidades unidades',
                          icone: Icons.emoji_events_rounded,
                          corIcone: Colors.yellow,
                          corCard: corCard,
                          corBorda: corBorda,
                          corTexto: corTextoPrincipal,
                          corMuted: corTextoMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Seção de Estatísticas (Gráficos)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: corCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: corBorda, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Grafico 1: Top Marcas
                          _construirSecaoBarraTitulo('Top Marcas no Stock', corPrimaria, corTextoPrincipal),
                          const SizedBox(height: 16),
                          if (topMarcas.isEmpty)
                            const Text('Sem dados suficientes.', style: TextStyle(color: corTextoMuted))
                          else
                            ...topMarcas.map((e) {
                              final pct = totalVeiculos > 0 ? (e.value / totalVeiculos) : 0.0;
                              return _construirGraficoBarra(
                                label: e.key,
                                valor: '${e.value}',
                                porcentagemStr: '${(pct * 100).toStringAsFixed(0)}%',
                                porcentagem: pct,
                                corBarra: corPrimaria,
                                corTexto: corTextoPrincipal,
                                corMuted: corTextoMuted,
                              );
                            }),
                          const SizedBox(height: 24),
                          
                          // Grafico 2: Classificação por Idade
                          _construirSecaoBarraTitulo('Classificação por Idade', corPrimaria, corTextoPrincipal),
                          const SizedBox(height: 16),
                          _construirGraficoBarra(
                            label: 'Novos (0-2 anos)',
                            valor: '$totalNovos',
                            porcentagemStr: '${totalVeiculos > 0 ? ((totalNovos / totalVeiculos) * 100).toStringAsFixed(0) : 0}%',
                            porcentagem: totalVeiculos > 0 ? (totalNovos / totalVeiculos) : 0.0,
                            corBarra: Colors.cyanAccent,
                            corTexto: corTextoPrincipal,
                            corMuted: corTextoMuted,
                          ),
                          _construirGraficoBarra(
                            label: 'Seminovos (3-5 anos)',
                            valor: '$totalSeminovos',
                            porcentagemStr: '${totalVeiculos > 0 ? ((totalSeminovos / totalVeiculos) * 100).toStringAsFixed(0) : 0}%',
                            porcentagem: totalVeiculos > 0 ? (totalSeminovos / totalVeiculos) : 0.0,
                            corBarra: Colors.blueAccent,
                            corTexto: corTextoPrincipal,
                            corMuted: corTextoMuted,
                          ),
                          _construirGraficoBarra(
                            label: 'Clássicos (6+ anos)',
                            valor: '$totalClassicos',
                            porcentagemStr: '${totalVeiculos > 0 ? ((totalClassicos / totalVeiculos) * 100).toStringAsFixed(0) : 0}%',
                            porcentagem: totalVeiculos > 0 ? (totalClassicos / totalVeiculos) : 0.0,
                            corBarra: Colors.amber,
                            corTexto: corTextoPrincipal,
                            corMuted: corTextoMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filtros e Pesquisa de Veículos
                    _construirSecaoFiltros(corCard, corBorda, corTextoPrincipal, corTextoMuted, corPrimaria),
                    const SizedBox(height: 20),

                    // Inventário de Stock (Lista de Carros)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FROTA DE VEÍCULOS',
                              style: TextStyle(color: corPrimaria, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inventário de Stock',
                              style: TextStyle(color: corTextoPrincipal, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Ordenação Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: corCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: corBorda),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _ordenacaoSelecionada,
                              dropdownColor: corCard,
                              style: const TextStyle(color: corTextoPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 'Ano: Recente', child: Text('Ano: Recente')),
                                DropdownMenuItem(value: 'Ano: Antigo', child: Text('Ano: Antigo')),
                                DropdownMenuItem(value: 'Nome', child: Text('Nome')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _ordenacaoSelecionada = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (viewModel.mensagemErro != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: corPrimaria.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: corPrimaria.withOpacity(0.3)),
                        ),
                        child: Text(
                          viewModel.mensagemErro!,
                          style: const TextStyle(color: corPrimaria),
                        ),
                      ),

                    // Lista de Cards
                    carrosFiltrados.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: corCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: corBorda),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: corTextoMuted),
                                SizedBox(height: 12),
                                Text(
                                  'Nenhum veículo encontrado.',
                                  style: TextStyle(color: corTextoMuted, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: carrosFiltrados.length,
                            itemBuilder: (ctx, index) {
                              final carro = carrosFiltrados[index];
                              return _construirVeiculoCard(carro, corCard, corBorda, corPrimaria, corTextoPrincipal, corTextoMuted);
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogoAdicionar(context, viewModel),
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Adicionar Carro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _construirKpiCard({
    required String titulo,
    required String valor,
    required String legenda,
    required IconData icone,
    required Color corIcone,
    required Color corCard,
    required Color corBorda,
    required Color corTexto,
    required Color corMuted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBorda, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(color: corMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icone, color: corIcone, size: 16),
            ],
          ),
          Text(
            valor,
            style: TextStyle(color: corTexto, fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            legenda,
            style: TextStyle(color: corMuted.withOpacity(0.7), fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _construirSecaoBarraTitulo(String titulo, Color corPrimaria, Color corTextoPrincipal) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: corPrimaria),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: TextStyle(color: corTextoPrincipal, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _construirGraficoBarra({
    required String label,
    required String valor,
    required String porcentagemStr,
    required double porcentagem,
    required Color corBarra,
    required Color corTexto,
    required Color corMuted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: corTexto, fontSize: 13, fontWeight: FontWeight.bold)),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: corTexto, fontFamily: 'Roboto'),
                  children: [
                    TextSpan(text: '$valor ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '($porcentagemStr)', style: TextStyle(color: corMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentagem,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E2128),
              valueColor: AlwaysStoppedAnimation<Color>(corBarra),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSecaoFiltros(Color corCard, Color corBorda, Color corTextoPrincipal, Color corTextoMuted, Color corPrimaria) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'FILTROS DE STOCK',
            style: TextStyle(color: corTextoMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            'Pesquisa Rápida',
            style: TextStyle(color: corTextoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _pesquisaController,
            style: TextStyle(color: corTextoPrincipal, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Nome, modelo ou código',
              hintStyle: TextStyle(color: corTextoMuted.withOpacity(0.5), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: corTextoMuted, size: 18),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              filled: true,
              fillColor: const Color(0xFF101115),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: corBorda, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: corPrimaria, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVeiculoCard(
    CarroDto carro,
    Color corCard,
    Color corBorda,
    Color corPrimaria,
    Color corTextoPrincipal,
    Color corTextoMuted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBorda),
      ),
      child: Row(
        children: [
          // Icone Carro Estilizado
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: corBorda),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFFFF3E56),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Informações do Veículo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${carro.codigo}',
                      style: const TextStyle(
                        color: Color(0xFFFF5266),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101115),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: corBorda),
                      ),
                      child: Text(
                        '${carro.ano}',
                        style: TextStyle(color: corTextoPrincipal, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  carro.nome,
                  style: TextStyle(
                    color: corTextoPrincipal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${carro.marca} — ${carro.modelo}',
                  style: TextStyle(color: corTextoMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Ação de Deletar
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmarExclusao(context, context.read<DashboardViewModel>(), carro.id, carro.nome),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, DashboardViewModel viewModel, int id, String nome) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13151A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Excluir Veículo', style: TextStyle(color: Color(0xFFF3F4F6), fontWeight: FontWeight.bold)),
          content: Text(
            'Tem certeza que deseja remover o veículo "$nome" do sistema?',
            style: const TextStyle(color: Color(0xFF8C92AC)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: Color(0xFF8C92AC), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final sucesso = await viewModel.deletarCarro(id);
                if (sucesso && context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veículo removido com sucesso.'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('EXCLUIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
