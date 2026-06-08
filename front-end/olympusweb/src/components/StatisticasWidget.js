// Aqui ele recebe duas listas(Arrays), onde esse codigo inteiro calcula indicadores e exibe estatiscas com base desses Arrays
export default function StatisticasWidget({ carros = [], carrosFiltrados = [] }) {
  // Aqui é parte do controle geral do stock, onde mostra o numero de total de carros do stock
  const totalGeral = carros.length;
  // Aqui mostra numero de carros que passa pelos filtros atuais
  const totalFiltrado = carrosFiltrados.length;
  // Aqui é usado para categorizar as idades dos veiculos
  const anoAtual = new Date().getFullYear();

  // Marcas
  const marcasGeral = new Set(carros.map((c) => c.marca).filter(Boolean));
  const marcasFiltradas = new Set(carrosFiltrados.map((c) => c.marca).filter(Boolean));

  // Recentes (Ano >= AnoAtual - 5)
  const recentesGeral = carros.filter((c) => Number(c.ano) >= anoAtual - 5).length;
  const recentesFiltrados = carrosFiltrados.filter((c) => Number(c.ano) >= anoAtual - 5).length;

  // Líder de Stock (na seleção filtrada)
  const contagemMarcas = carrosFiltrados.reduce((acc, c) => {
    if (c.marca) {
      acc[c.marca] = (acc[c.marca] || 0) + 1;
    }
    return acc;
  }, {});

  // Aqui é quando não acha nenhum dado para o carro lider de stock
  let liderStock = 'Nenhuma';
  let liderQtd = 0;
  Object.entries(contagemMarcas).forEach(([marca, qtd]) => {
    if (qtd > liderQtd) {
      liderQtd = qtd;
      liderStock = marca;
    }
  });

  // Distribuição de Categorias por Idade (para os carros filtrados)
  const novos = carrosFiltrados.filter((c) => Number(c.ano) >= anoAtual - 2).length;
  const seminovos = carrosFiltrados.filter((c) => Number(c.ano) >= anoAtual - 5 && Number(c.ano) < anoAtual - 2).length;
  const classicos = carrosFiltrados.filter((c) => Number(c.ano) < anoAtual - 5).length;

  // Aqui é um calculo de porcentagem relativa dentro do conjulto filtrado
  const pctNovos = totalFiltrado > 0 ? (novos / totalFiltrado) * 100 : 0;
  const pctSeminovos = totalFiltrado > 0 ? (seminovos / totalFiltrado) * 100 : 0;
  const pctClassicos = totalFiltrado > 0 ? (classicos / totalFiltrado) * 100 : 0;

  // Top 4 Marcas na seleção filtrada
  const topMarcas = Object.entries(contagemMarcas)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 4);

  return (
    // Aqui são os KPI do JSX, essa aqui é a estrutura do widget do total de veiculos, tanto os os gereais e filtrados
    <section id="estatisticas" className="dashboard-stats-section">
      <div className="stats-cards-grid">
        <div className="kpi-card">
          <div className="kpi-icon">🚗</div>
          <div className="kpi-content">
            <span>Total de Veículos</span>
            <strong>{totalFiltrado}</strong>
            <small>{totalFiltrado !== totalGeral ? `${totalGeral - totalFiltrado} filtrados` : `Total em stock`}</small>
          </div>
        </div>

        {/* Aqui é o widget falando a quantidade de marcas disponiveis no stock */}
        <div className="kpi-card">
          <div className="kpi-icon">🏷️</div>
          <div className="kpi-content">
            <span>Marcas Registadas</span>
            <strong>{marcasFiltradas.size}</strong>
            <small>{`de ${marcasGeral.size} disponíveis`}</small>
          </div>
        </div>

        {/* Aqui é um widget que marca os carros com ano de fabricação dos ultimos anos */}
        <div className="kpi-card">
          <div className="kpi-icon">⚡</div>
          <div className="kpi-content">
            <span>Veículos Recentes</span>
            <strong>{recentesFiltrados}</strong>
            <small>{`${recentesGeral} no total geral`}</small>
          </div>
        </div>

        {/* Aqui é o widget de lider do stock com o sistema  de lider de stock de cima*/}
        <div className="kpi-card">
          <div className="kpi-icon">🏆</div>
          <div className="kpi-content">
            <span>Líder de Stock</span>
            <strong>{liderStock}</strong>
            <small>{liderQtd > 0 ? `${liderQtd} unidades` : 'Sem stock'}</small>
          </div>
        </div>
      </div>

      {/* Aqui é o sistema do top de marcas do stock, onde se ele não encontrar nada no stock, ele retorna que tem nenhum dado para exibir */}
      <div className="charts-grid">
        {/* Distribuição por Marcas */}
        <div className="chart-card">
          <h3>Top Marcas no Stock</h3>
          {topMarcas.length === 0 ? (
            <p className="no-data">Nenhum dado para exibir.</p>
          ) : (
            <div className="custom-chart-bars">
              {topMarcas.map(([marca, qtd]) => {
                const pct = totalFiltrado > 0 ? (qtd / totalFiltrado) * 100 : 0;
                return (
                  <div key={marca} className="custom-bar-row">
                    <div className="bar-label">{marca}</div>
                    <div className="bar-track">
                      <div className="bar-fill brand" style={{ width: `${pct}%` }}></div>
                    </div>
                    <div className="bar-value">
                      {qtd} <small>({Math.round(pct)}%)</small>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
        
        {/* Distribuição por Época */}
        <div className="chart-card">
          <h3>Classificação por Idade</h3>
          {/* Aqui é uma tomanda de decisão para ver se tem algum carro no stock */}
          {totalFiltrado === 0 ? (
            <p className="no-data">Nenhum dado para exibir.</p>
          ) : (
            //  Aqui é o widget do grafico de carros novos ( De 0 a 2 anos de fabricação )
            <div className="custom-chart-bars">
              <div className="custom-bar-row">
                <div className="bar-label">Novos <span className="label-year">(0-2 anos)</span></div>
                <div className="bar-track">
                  <div className="bar-fill new" style={{ width: `${pctNovos}%` }}></div>
                </div>
                <div className="bar-value">
                  {novos} <small>({Math.round(pctNovos)}%)</small>
                </div>
              </div>

              {/* Aqui é o grafico de SemiNovos ( De 3 a 5 anos de fabricação )*/}
              <div className="custom-bar-row">
                <div className="bar-label">Seminovos <span className="label-year">(3-5 anos)</span></div>
                <div className="bar-track">
                  <div className="bar-fill semi" style={{ width: `${pctSeminovos}%` }}></div>
                </div>
                <div className="bar-value">
                  {seminovos} <small>({Math.round(pctSeminovos)}%)</small>
                </div>
              </div>

              {/* Aqui é o grafico de carros classicão ( De 6+ de fabricação pra mais )*/}
              <div className="custom-bar-row">
                <div className="bar-label">Clássicos <span className="label-year">(6+ anos)</span></div>
                <div className="bar-track">
                  <div className="bar-fill classic" style={{ width: `${pctClassicos}%` }}></div>
                </div>
                <div className="bar-value">
                  {classicos} <small>({Math.round(pctClassicos)}%)</small>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
