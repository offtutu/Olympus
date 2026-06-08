// Aqui ele desmonta o PROPS em varios objetos que vão ser utilizados nessa projetção do widget
export default function ListaCarrosWidget({
  carros = [],
  totalNaoFiltrado = 0,
  carregando,
  aoEditar,
  aoDeletar,
  ordenacao,
  setOrdenacao,
}) {
  // Aqui é a funcionalidade do objeto carregando, onde ele serve para carregar o stock de carros
  if (carregando) {
    return (
      <section id="carros" className="widget loading-widget">
        <div className="loading-spinner-container">
          <div className="loading-spinner"></div>
          <p>A carregar o inventário de veículos...</p>
        </div>
      </section>
    );
  }

  // Aqui ele retorna o stock de carros
  return (
    <section id="carros" className="widget list-widget">
      <div className="widget-header">
        {/* Aqui fica o cabeçario do inventario do stock*/}
        <div>
          <span>Frota de Veículos</span>
          <h2>Inventário de Stock</h2>
        </div>

        {/*Aqui é um seletor de opçãos para a ordem de organização do stock, onde vai de recente, antigo, A-Z, Z-A e o codigo do carro. Ele foi utilização o objeto de ordenacao. */}
        <div className="sorting-container">
          <label htmlFor="ordenar-carros">Ordenar por:</label>
          <select
            id="ordenar-carros"
            value={ordenacao}
            onChange={(e) => setOrdenacao(e.target.value)}
          >
            <option value="ano-desc">Ano: Recente</option>
            <option value="ano-asc">Ano: Antigo</option>
            <option value="nome-asc">Nome: A-Z</option>
            <option value="nome-desc">Nome: Z-A</option>
            <option value="codigo-asc">Código do Carro</option>
          </select>
        </div>
      </div>

      {/* Aqui retorna uma mensagem quando não tem nenhum veiculo encontrado no stock ou quando não conseguem encontrar algum veiculo que corresponda aos filtros de busca. Se encontrar algum veiculo ele manda o formato de widget de listagem dos carros*/}
      {carros.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">🔍</div>
          <h3>Nenhum veículo encontrado</h3>
          <p>
            {totalNaoFiltrado === 0
              ? 'O stock está vazio. Adicione o seu primeiro veículo usando o botão no topo.'
              : 'Não existem veículos que correspondam aos filtros selecionados na barra lateral.'}
          </p>
        </div> 
      ) : ( 
        <div className="carros-grid">
          {/* Aqui percorre a lista dos carros e para cada id de carro encontrado, ele cria um card paras os carros   */}
          {carros.map((carro) => (
            <article key={carro.id} className="carro-card">
              <div className="carro-card-header">
                <span className="carro-code-tag">#{carro.codigo}</span>
                <span className="carro-year-badge">{carro.ano}</span>
              </div>

              {/* Aqui é o corpo do card com as informações e etc... */}
              <div className="carro-card-body">
                <h3 className="carro-name">{carro.nome}</h3>
                <div className="carro-details-grid">
                  <div className="detail-item">
                    <span className="detail-title">Marca</span>
                    <span className="detail-value">{carro.marca}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-title">Modelo</span>
                    <span className="detail-value">{carro.modelo}</span>
                  </div>
                </div>
              </div>

              {/* Aqui é os botoões de deletar e editar os carro no card */}
              <div className="carro-card-actions">
                <button type="button" className="btn-edit" onClick={() => aoEditar(carro)}>
                  Editar
                </button>
                <button type="button" className="btn-delete" onClick={() => aoDeletar(carro.id)}>
                  Deletar
                </button>
              </div>
            </article>
          ))}
        </div>
      )}
    </section>
  );
}
