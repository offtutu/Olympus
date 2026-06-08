// Aqui é a mesma coisa do ListaCarros, ele pega o PROPS e desmonta em varios objetos para facilicar no desenvolvimento
export default function Sidebar({
  filtroPesquisa,
  setFiltroPesquisa,
  filtroMarca,
  setFiltroMarca,
  filtroAnoMin,
  setFiltroAnoMin,
  filtroAnoMax,
  setFiltroAnoMax,
  marcasDisponiveis = [],
  aoLimparFiltros,
  onLogout,
}) {
  // Aqui ve se tem algum filtro ativo, ele serve para disponibilizar o botão de limpar filtro, caso tenha algum, o botão aparece
  const temFiltrosAtivos = filtroPesquisa || filtroMarca || filtroAnoMin || filtroAnoMax;

  return (
    // Aqui é a construção do cabeçario da barra lateral
    <aside className="sidebar">
      <div className="sidebar-logo">
        <img className="logo-mark" src="/olympuslogo.png" alt="Logo Olympus" />
        <div>
          <strong>OlympusMotors</strong>
          <small>Stock & Cadastro</small>
        </div>
      </div>

      {/* Aqui é a parte de navegação rapida, onde ele te dá o acesso rapido para a dashboard que seria o painel principal, da acesso as estasticas e ao stock de carro  */}
      <nav className="sidebar-nav">
        <a href="#dashboard" className="active">Painel Principal</a>
        <a href="#estatisticas">Estatísticas</a>
        <a href="#carros">Inventário</a>
      </nav>

      {/* Aqui é uma divisão para separar a naveção rapida dos filtros */}
      <div className="sidebar-divider"></div>

      {/* Aqui é o cabeçario dos filtros */}
      <section className="sidebar-filters">
        <h3>Filtros de Stock</h3>
        
        {/* Aqui é sistema de filtro de pesquisa rapida, onde só de você colocar qualquer especificação de um carro já vai aparecer . o sistema de procura desse daqui é de text input */}
        <div className="filter-group">
          <label htmlFor="filtro-busca">Pesquisa Rápida</label>
          <input
            id="filtro-busca"
            type="text"
            placeholder="Nome, modelo ou código"
            value={filtroPesquisa}
            onChange={(e) => setFiltroPesquisa(e.target.value)}
          />
        </div>

        {/* Aqui é o sistema de filtro mais especifico, onde ele serve para procurar pelas marcas dos carros já cadastrados, ele é muito utilizado para procurar modelos de carros de marcas especificas. o sistema dele é de select dropdown */}
        <div className="filter-group">
          <label htmlFor="filtro-marca">Filtrar por Marca</label>
          <select
            id="filtro-marca"
            value={filtroMarca}
            onChange={(e) => setFiltroMarca(e.target.value)}
          >
            <option value="">Todas as Marcas</option>
            {marcasDisponiveis.map((marca) => (
              <option key={marca} value={marca}>
                {marca}
              </option>
            ))}
          </select>
        </div>
        
        {/* aqui é um sistema de filtro por intervalo de anos, onde o funcionario coloca um ano minimo e um ano maximo para pesquisa, ai aperece os carros nessa faixetaria de ano. o sistema dele é de number input */}
        <div className="filter-group">
          <label>Intervalo de Anos</label>
          <div className="range-inputs">
            <input
              type="number"
              placeholder="Mín"
              value={filtroAnoMin}
              onChange={(e) => setFiltroAnoMin(e.target.value)}
            />
            <span className="range-separator">-</span>
            <input
              type="number"
              placeholder="Máx"
              value={filtroAnoMax}
              onChange={(e) => setFiltroAnoMax(e.target.value)}
            />
          </div>
        </div>
        
        {/* Aqui é o botão de limpar filtro, como dito anteriormente */}
        {temFiltrosAtivos && (
          <button className="btn-reset" type="button" onClick={aoLimparFiltros}>
            Limpar Filtros
          </button>
        )}
      </section>

      {/* Aqui é a parte final da sidebar, onde adicionamos um divisor e o botão de Sair do sistema */}
      <div className="sidebar-divider" style={{ marginTop: '24px', marginBottom: '16px' }}></div>
      
      <div className="sidebar-footer" style={{ marginTop: 'auto' }}>
        <button 
          className="btn-logout" 
          type="button" 
          onClick={onLogout}
          style={{
            width: '100%',
            padding: '12px 14px',
            background: 'rgba(230, 57, 70, 0.08)',
            border: '1px solid rgba(230, 57, 70, 0.2)',
            borderRadius: 'var(--radius-sm)',
            color: '#e63946',
            fontSize: '14px',
            fontWeight: '600',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            transition: 'var(--transition-smooth)'
          }}
          // Efeitos de animação ao passar o mouse
          onMouseEnter={(e) => {
            e.currentTarget.style.background = 'var(--primary)';
            e.currentTarget.style.color = '#fff';
            e.currentTarget.style.boxShadow = '0 4px 12px var(--primary-glow)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.background = 'rgba(230, 57, 70, 0.08)';
            e.currentTarget.style.color = '#e63946';
            e.currentTarget.style.boxShadow = 'none';
          }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
            <polyline points="16 17 21 12 16 7"></polyline>
            <line x1="21" y1="12" x2="9" y2="12"></line>
          </svg>
          Sair do Sistema
        </button>
      </div>
    </aside>
  );
}
