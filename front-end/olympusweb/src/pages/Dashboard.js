// Aqui são os imports para montar a dashboard
import { useEffect, useState } from 'react';
import Sidebar from '../components/Sidebar';
import ListaCarrosWidget from '../components/ListaCarrosWidget';
import StatisticasWidget from '../components/StatisticasWidget';
import Modal from '../components/Modal';
import { atualizarCarro, criarCarro, listarCarros, removerCarro } from '../services/CarrosService';

// Aqui é um sistema de memoria mockado para ajudar no desenvolvimento do front-end sem precisar ficar ligando a API sempre(Meu notebook agradece)
const CARROS_MOCK = [
  { id: 1, codigo: 1001, nome: 'Porsche 911 Carrera', marca: 'Porsche', modelo: '911 Carrera S', ano: 2023 },
  { id: 2, codigo: 1002, nome: 'Mustang Shelby GT500', marca: 'Ford', modelo: 'Shelby GT500', ano: 2022 },
  { id: 3, codigo: 1003, nome: 'Civic Type R', marca: 'Honda', modelo: 'Type R', ano: 2023 },
  { id: 4, codigo: 1004, nome: 'M4 Competition', marca: 'BMW', modelo: 'M4 Coupe', ano: 2024 },
  { id: 5, codigo: 1005, nome: 'Model S Plaid', marca: 'Tesla', modelo: 'Model S Plaid', ano: 2021 },
  { id: 6, codigo: 1006, nome: 'GR Yaris', marca: 'Toyota', modelo: 'GR Yaris', ano: 2023 },
  { id: 7, codigo: 1007, nome: 'Audi RS6 Avant', marca: 'Audi', modelo: 'RS6 Performance', ano: 2024 },
  { id: 8, codigo: 1008, nome: 'F40 LM', marca: 'Ferrari', modelo: 'F40', ano: 1992 },
  { id: 9, codigo: 1009, nome: 'Lamborghini Revuelto', marca: 'Lamborghini', modelo: 'Revuelto', ano: 2024 },
  { id: 10, codigo: 10010, nome: 'Porsche 911 Targa GTS', marca: 'Porsche', modelo: '911 Targa GTS', ano: 2024 },
];

// Aqui é o formulario basico de todos os carros
const formularioInicial = {
  codigo: '',
  nome: '',
  marca: '',
  modelo: '',
  ano: '',
};

// Aqui é uma declaração, onde declara todos os componentes que vão ser utilizados dentro da Dashboard e seus estados 
export default function Dashboard({ onLogout, defaultModoDemo = false }) {
  const [carros, setCarros] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [modalAberto, setModalAberto] = useState(false);
  const [carroEditar, setCarroEditar] = useState(null);
  const [formData, setFormData] = useState(formularioInicial);
  
  // Estados de Conexão e Filtros
  const [modoDemo, setModoDemo] = useState(defaultModoDemo); // Aqui o sistema de conexão para facilitar o desenvolvimento, porque meu notebook é buxento e não tanka tanta coisa aberta. O mod demo ele serve para eu visualizar o sistema por inteiro sem depender do banco de dados, já que ele utiliza os dados mockados que são os dados locais.
  const [filtroPesquisa, setFiltroPesquisa] = useState('');
  const [filtroMarca, setFiltroMarca] = useState('');
  const [filtroAnoMin, setFiltroAnoMin] = useState('');
  const [filtroAnoMax, setFiltroAnoMax] = useState('');
  const [ordenacao, setOrdenacao] = useState('ano-desc'); // Aqui é um aviso de como os carros devem ser ordenados, que no caso seria na ordem decresente pelo ano dos carros

  // Aqui é sistema para buscar os dados dos carros para o stock
  const buscarCarros = async () => {
    // Aqui verifica se o modo demo já está ativo para usar os carros locais diretamente sem carregar a API
    if (modoDemo) {
      setCarregando(true);
      setCarros((prevCarros) => (prevCarros.length > 0 ? prevCarros : CARROS_MOCK));
      setCarregando(false);
      return;
    }

    // Aqui é um tratamento de erro, para ver se o sistema utiliza o dado de carros locais que seria o modo demo ou se ele já tem conexão com o banco de dados e a API do back.
    try {
      // Aqui é os sistema de carregamento com a API (Que utiliza os dados do back-end)
      setCarregando(true);
      const dados = await listarCarros(); // Aqui é o comando para o sistema ter os dados do banco de dados, onde ele utiliza o comando listar carros do Services
      setCarros(dados);
      setModoDemo(false); // Se o sistema conseguir carregar os dados tudo certinho, o modo demo retorna como false por conta do modo "Online" estar ligado
      // Se o sistema não conseguir carregar os dados, ele retorna um erro e entra no modo demo que seriaa o modo offline
    } catch (error) {
      console.warn('Servidor offline. Carregando dados locais de simulação:', error);
      setModoDemo(true);
      // Aqui mantém os carros locais se o usuário já fez alguma alteração temporária dentro do site
      setCarros((prevCarros) => (prevCarros.length > 0 ? prevCarros : CARROS_MOCK));
    } finally {
      setCarregando(false);
    }
  };

  // Aqui é um comando para buscar os carros assim que os componentes do dash são carregados pela primeira vez na inicialização do sistema
  useEffect(() => {
    buscarCarros();
  }, []); // Essa lista vazia avisa que que o comando tem que executar isso uma unica vez quando o sistema inicializa

  // Aqui é a abertura do sistema de cadastro de carros para o stock
  const abrirCadastro = () => {
    setCarroEditar(null);
    setFormData(formularioInicial);
    setModalAberto(true);
  };

  // Aqui é a abertura do sistema de edição de carros no stock
  const abrirEdicao = (carro) => {
    setCarroEditar(carro);
    setFormData(carro);
    setModalAberto(true);
  };

  // Aqui é fechamento do modal que são basicamente os widgets reutilizavel
  const fecharModal = () => {
    setModalAberto(false);
    setCarroEditar(null);
    setFormData(formularioInicial);
  };

  // Aqui é um monitoramento de quando o usuario digita algo nos campos e o sistema já atualiza com os novos valores. Ele é basicamente o ouvidor dos inputs
  const handleChange = (evento) => {
    const { name, value } = evento.target;
    setFormData({
      ...formData,
      [name]: name === 'codigo' || name === 'ano' ? parseInt(value) || '' : value,
    });
  };
  
  // Aqui é o sistema de controle de atualizações de mudanças feita por botões
  const handleSubmit = async (evento) => {
    evento.preventDefault(); // De vez de apenas atualizar a pagina, o prevenDefault retorna uma mensagem falando se a alteração foi completa ou não e fecha o modal aberto, se a alteração foi completa, até a confirmaçãao da mensagem, os dados não são atualizados.

    // Aqui é umt tratamento de erros para o sistema de edição tanto para o modo demo e tanto para o modo online
    try {
      // Aqui é funcionalidade de edição de carros só que no modo Demo
      if (modoDemo) {
        if (carroEditar) {
          // Atualiza em memória
          setCarros(carros.map((c) => (c.id === carroEditar.id ? { ...formData, id: carroEditar.id } : c)));
          alert('Carro atualizado com sucesso (Modo Demo)');
        } else {
          // Cria em memória
          const novoCarro = {
            ...formData,
            id: Date.now(),
          };
          setCarros([novoCarro, ...carros]);
          alert('Carro criado com sucesso (Modo Demo)');
        }
        fecharModal();
      // Aqui já é a edição com o sistema já no modo online
      } else {
        if (carroEditar) {
          await atualizarCarro(carroEditar.id, formData);
          alert('Carro atualizado com sucesso');
        } else {
          await criarCarro(formData);
          alert('Carro criado com sucesso');
        }
        fecharModal();
        buscarCarros();
      }
      // Aqui é fechamento do tratamento de erros, quando independente do modo de conexão que está o sistema, ele retorna um erro quando o sistema não consegue excecutar a funcionalidade do sistema de edição de informação dos carros
    } catch (error) {
      alert('Erro ao salvar carro: ' + error.message);
    }
  };

  // Aqui é o sistema de verificação e confirmação do botão de delete, onde ele serve mais como um meio de segurança, caso o usuario tenha apertado no botão ou o produto errado
  const handleDeletar = async (id) => {
    if (!window.confirm('Tem certeza que você deseja deletar esse carro?')) {
      return;
    }

    // Aqui é o tratamento de erro para ambas conexões
    try {
      // Aqui a função sendo utilizada no modo Demo
      if (modoDemo) {
        setCarros(carros.filter((c) => c.id !== id));
        alert('Carro deletado com sucesso (Modo Demo)');
      // Aqu é a função sendo utilizada no modo Online
      } else {
        await removerCarro(id);
        alert('Carro deletado com sucesso');
        buscarCarros();
      }
      // Aqui é o fechamento do tratamento de erros, igual no sistema de edição, independente dos sistema de conexão que está ativo, retorna um erro, caso o sistema não consiga executar a função corretamente
    } catch (error) {
      alert('Erro ao deletar carro: ' + error.message);
    }
  };

  // Aqui é o botão de limpeza de filtro, onde se qualquer campo esteja preenchido, ele retorna para a forma padrão do campo
  const aoLimparFiltros = () => {
    setFiltroPesquisa('');
    setFiltroMarca(''); // Aqui ele retorna o filtro por marca para a opção "Todas as marcas"
    setFiltroAnoMin('');
    setFiltroAnoMax('');
  };

  // Aqui é o sitema de filtragem para ele agir corretamente em cima dos conformes.
  const carrosFiltrados = carros.filter((carro) => {
    const correspondePesquisa =
      !filtroPesquisa ||
      carro.nome.toLowerCase().includes(filtroPesquisa.toLowerCase()) ||
      carro.modelo.toLowerCase().includes(filtroPesquisa.toLowerCase()) ||
      carro.codigo.toString().includes(filtroPesquisa);

    const correspondeMarca = !filtroMarca || carro.marca === filtroMarca;

    const correspondeAnoMin = !filtroAnoMin || Number(carro.ano) >= Number(filtroAnoMin);

    const correspondeAnoMax = !filtroAnoMax || Number(carro.ano) <= Number(filtroAnoMax);

    return correspondePesquisa && correspondeMarca && correspondeAnoMin && correspondeAnoMax;
  });

  // Aqui é o sistema de ordenação que fica na parte do stock
  const carrosOrdenados = [...carrosFiltrados].sort((a, b) => {
    if (ordenacao === 'ano-desc') return Number(b.ano) - Number(a.ano);
    if (ordenacao === 'ano-asc') return Number(a.ano) - Number(b.ano);
    if (ordenacao === 'nome-asc') return a.nome.localeCompare(b.nome);
    if (ordenacao === 'nome-desc') return b.nome.localeCompare(a.nome);
    if (ordenacao === 'codigo-asc') return Number(a.codigo) - Number(b.codigo);
    return 0;
  });

  // Lista dinâmica de marcas no banco para o filtro lateral, onde ele libera uma lista de marcas disponiveis em cima das marcas registradas no stock
  const marcasDisponiveis = Array.from(new Set(carros.map((c) => c.marca).filter(Boolean))).sort();

  return (
    // Aqui é a abertura da inferface geral do dashbord
    <div className="dashboard-shell" id="dashboard">
      {/* Aqui é a sidebar, com suas funcionalidades de filtro*/}
      <Sidebar
        filtroPesquisa={filtroPesquisa}
        setFiltroPesquisa={setFiltroPesquisa}
        filtroMarca={filtroMarca}
        setFiltroMarca={setFiltroMarca}
        filtroAnoMin={filtroAnoMin}
        setFiltroAnoMin={setFiltroAnoMin}
        filtroAnoMax={filtroAnoMax}
        setFiltroAnoMax={setFiltroAnoMax}
        marcasDisponiveis={marcasDisponiveis}
        aoLimparFiltros={aoLimparFiltros}
        onLogout={onLogout}
      />

      {/* Aqui já é o painel principal */}
      <main className="dashboard-main">
        {/* Aqui é o cabeçario do painel*/}
        <header className="dashboard-header">
          <div>
            <span>Painel Olympus Motors</span>
            <div className="header-title-row">
              <h1>Controle de Stock</h1>
              {/* Aqui é uma pequena verificação para ver se o server tá usando a conexão demo que seria a offline ou a conexão com o server que seria a online, após a verificação ele retorna uma badge para o usuario do site ficar ciente de qual modo conexão ele está */}
              {modoDemo ? (
                <span className="status-badge demo">Modo Demo (Offline)</span>
              ) : (
                <span className="status-badge online">Conectado ao Servidor</span>
              )}
            </div>
          </div>
          
          {/* Aqui é o botão para o cadastro de carros ao stock */}
          <button className="btn-primary" type="button" onClick={abrirCadastro}>
            + Adicionar Carro
          </button>
        </header>
        
        {/* Aqui mostra as estatiscas do carros, que são o total de veiculos, total de marcas registradas e por assim vai...   */}
        <StatisticasWidget carros={carros} carrosFiltrados={carrosFiltrados} />
        
        {/* Aqui mostra a tabela dos carros */}
        <ListaCarrosWidget
          carros={carrosOrdenados}
          totalNaoFiltrado={carros.length}
          carregando={carregando}
          aoEditar={abrirEdicao}
          aoDeletar={handleDeletar}
          ordenacao={ordenacao}
          setOrdenacao={setOrdenacao}
        />
      </main>

      {/* Aqui já a abertura do modal para cadastrar veiculos e para atualizar os veiculos */}       
      <Modal
        aberto={modalAberto}
        titulo={carroEditar ? 'Atualizar Veículo' : 'Cadastrar Novo Veículo'}
        aoFechar={fecharModal}
      >
        
        <form onSubmit={handleSubmit} className="carro-form">
          {/* Aqui é o input de codigo, com o nome do input, o seu id e o seu valor. Ele também tem um exemplo para os mais leigos na parte do cadastro  */}
          <div className="form-group">
            <label htmlFor="codigo">Código do Veículo</label>
            <input
              name="codigo"
              id="codigo"
              type="number"
              value={formData.codigo}
              onChange={handleChange}
              placeholder="Ex: 1009" 
              required
            />
          </div>
          
          {/* Aqui é a parte do input do nome do veiculo */}
          <div className="form-group">
            <label htmlFor="nome">Nome do Modelo</label>
            <input
              name="nome"
              id="nome"
              type="text"
              value={formData.nome}
              onChange={handleChange}
              placeholder="Ex: 911 Turbo S"
              required
            />
          </div>
          
          {/* Aqui é um div para poder agrupar o input de Marca e a Linha do carro, para deixar mais organizado e bonito */}
          <div className="form-row-2">
            {/* Aqui é o input de marca igual todos os outros inputs anteriores */}
            <div className="form-group">
              <label htmlFor="marca">Marca</label>
              <input
                name="marca"
                id="marca"
                type="text"
                value={formData.marca}
                onChange={handleChange}
                placeholder="Ex: Porsche"
                required
              />
            </div>
            
            {/* Aqui é o input do modelo do carro */}
            <div className="form-group">
              <label htmlFor="modelo">Linha/Modelo</label>
              <input
                name="modelo"
                id="modelo"
                type="text"
                value={formData.modelo}
                onChange={handleChange}
                placeholder="Ex: Coupé"
                required
              />
            </div>
          </div>
          
          {/* Aqui é o input do aano de fabricação do carro  */}
          <div className="form-group">
            <label htmlFor="ano">Ano de fabricação </label>
            <input
              name="ano"
              id="ano"
              type="number"
              value={formData.ano}
              onChange={handleChange}
              placeholder="Ex: 2024"
              required
            />
          </div>
          
          {/* Aqui é os botões para salvar a alteração caso a função foi editar/atualizar o carro ou o botão de confirmar cadastro caso a função que o modal foi aberto era a do formulario de caadastro */}
          <div className="form-actions">
            <button type="submit" className="btn-primary">
              {carroEditar ? 'Salvar Alterações' : 'Confirmar Cadastro'}
            </button>
            {/* Aqui é o botão de cancelar */}
            <button type="button" className="btn-secondary" onClick={fecharModal}>
              Cancelar
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
