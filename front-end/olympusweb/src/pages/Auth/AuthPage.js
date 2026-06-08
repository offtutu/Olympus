// Importações do React para gerenciar os estados locais e ciclo de vida
import { useState, useEffect } from 'react';
// Importação dos serviços de autenticação do CarrosService
import { fazerLogin, cadastrarUsuario } from '../../services/CarrosService';
// Folha de estilos exclusiva para a tela de Autenticação
import './AuthPage.css';

// Aqui é a declaração do componente principal da tela de Login e Registro
export default function AuthPage({ onLogin }) {
  // Estados para chavear entre tela de Login (true) e Registro (false)
  const [isLogin, setIsLogin] = useState(true);
  
  // Estado para controlar se estamos usando o Modo Demo (Offline) ou API Online
  const [modoDemo, setModoDemo] = useState(true); // Iniciamos em true para facilitar a simulação inicial
  
  // Estados para os campos do formulário
  const [nomeCompleto, setNomeCompleto] = useState('');
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [cargo, setCargo] = useState('COMUM'); // ADMIN ou COMUM para teste fácil
  const [lembrarMe, setLembrarMe] = useState(false);
  const [termosAceitos, setTermosAceitos] = useState(false);

  // Estados para exibir/ocultar senhas
  const [showSenha, setShowSenha] = useState(false);
  const [showConfirmarSenha, setShowConfirmarSenha] = useState(false);

  // Estados para validações e erros
  const [erros, setErros] = useState({});
  const [erroGeral, setErroGeral] = useState('');
  const [loading, setLoading] = useState(false);
  const [registroSucesso, setRegistroSucesso] = useState(false);

  // Aqui é o monitoramento do Modo Demo para preencher credenciais mockadas automaticamente para facilitar o teste
  useEffect(() => {
    if (modoDemo && isLogin) {
      setEmail('admin@olympus.com');
      setSenha('admin123');
      setErros({});
      setErroGeral('');
    } else if (modoDemo && !isLogin) {
      setNomeCompleto('Phaeton');
      setEmail('faetontefilhododeusdosol@olympus.com');
      setSenha('euamoaramiel');
      setConfirmarSenha('euamoaramiel');
      setCargo('COMUM');
      setTermosAceitos(true);
      setErros({});
      setErroGeral('');
    } else {
      // Limpa os campos ao mudar para modo online para que o usuário digite à vontade
      setEmail('');
      setSenha('');
      setNomeCompleto('');
      setConfirmarSenha('');
      setCargo('COMUM');
      setTermosAceitos(false);
      setErros({});
      setErroGeral('');
    }
  }, [modoDemo, isLogin]);

  // Aqui faz a limpeza de erros e estados ao alternar entre Login e Registro
  const alternarModo = () => {
    setIsLogin(!isLogin);
    setErros({});
    setErroGeral('');
    setRegistroSucesso(false);
    setShowSenha(false);
    setShowConfirmarSenha(false);
  };

  // Aqui serve para validar os campos no front-end antes de mandar para a API
  const validarFormulario = () => {
    const novosErros = {};
    
    // Validando o e-mail
    if (!email) {
      novosErros.email = 'E-mail é obrigatório';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      novosErros.email = 'Insira um e-mail válido';
    }

    // Validando a senha (mínimo de 6 caracteres)
    if (!senha) {
      novosErros.senha = 'Senha é obrigatória';
    } else if (senha.length < 6) {
      novosErros.senha = 'A senha deve conter no mínimo 6 caracteres';
    }

    // Validações exclusivas da tela de Registro
    if (!isLogin) {
      if (!nomeCompleto.trim()) {
        novosErros.nomeCompleto = 'Nome completo é obrigatório';
      }
      if (senha !== confirmarSenha) {
        novosErros.confirmarSenha = 'As senhas não coincidem';
      }
      if (!termosAceitos) {
        novosErros.termosAceitos = 'Você precisa aceitar os Termos de Uso';
      }
    }

    setErros(novosErros);
    // Retorna true se não houver nenhuma chave de erro no objeto
    return Object.keys(novosErros).length === 0;
  };

  // Aqui é o submit do formulário que gerencia a entrada (Login) ou o cadastro (Registro)
  const handleSubmit = async (evento) => {
    evento.preventDefault();
    setErroGeral('');
    setRegistroSucesso(false);

    // Executa as validações do front-end
    if (!validarFormulario()) {
      return;
    }

    setLoading(true);

    try {
      if (isLogin) {
        // --- FLUXO DE LOGIN ---
        if (modoDemo) {
          // Simulação instantânea no modo Demo
          await new Promise((resolve) => setTimeout(resolve, 800));
          
          // Verifica se as credenciais coincidem com as mockadas
          if (
            (email === 'admin@olympus.com' && senha === 'admin123') ||
            (email === 'funcionario@olympus.com' && senha === 'comum123') ||
            (email === 'joao@olympus.com' && senha === 'olympus123')
          ) {
            const mockRole = email === 'admin@olympus.com' ? 'ADMIN' : 'COMUM';
            onLogin('token-demo-123456', mockRole, true);
          } else {
            setErroGeral('Credenciais demo incorretas! Use admin@olympus.com / admin123');
          }
        } else {
          // Chamada real para o backend Spring Boot
          const response = await fazerLogin(email, senha);
          // O controller retorna o DTO { token: "..." }
          if (response && response.token) {
            // Nota: O backend valida a role ao processar o token, assumimos o fluxo principal
            onLogin(response.token, 'ADMIN', false); // Passa para o App.js logar online
          } else {
            setErroGeral('Resposta inválida do servidor de login.');
          }
        }
      } else {
        // --- FLUXO DE REGISTRO ---
        if (modoDemo) {
          // Simulação instantânea de registro no modo Demo
          await new Promise((resolve) => setTimeout(resolve, 1000));
          alert(`Conta criada com sucesso no Modo Demo!\nE-mail: ${email}\nCargo: ${cargo}`);
          setRegistroSucesso(true);
          setIsLogin(true); // Manda o usuário de volta para o login
        } else {
          // Chamada real para o endpoint de cadastro no Spring Boot
          await cadastrarUsuario(email, senha, cargo);
          alert('Cadastro realizado com sucesso! Faça seu login para acessar.');
          setRegistroSucesso(true);
          setIsLogin(true); // Vai para tela de login após cadastro bem sucedido
        }
      }
    } catch (error) {
      console.error('Erro na autenticação:', error);
      if (error.response && error.response.status === 400) {
        setErroGeral(isLogin ? 'E-mail ou senha incorretos.' : 'Este e-mail já está cadastrado no sistema.');
      } else if (error.response && error.response.status === 403) {
        setErroGeral('Acesso negado. Credenciais inválidas.');
      } else {
        setErroGeral('Não foi possível conectar ao servidor. Verifique se o backend está rodando ou use o Modo Demo.');
      }
    } finally {
      setLoading(false);
    }
  };

  // Aqui é a função de esqueci a senha para simular uma ação amigável ao usuário
  const handleEsqueciSenha = (e) => {
    e.preventDefault();
    if (!email) {
      alert('Por favor, digite seu e-mail no campo acima para que possamos enviar as instruções.');
      return;
    }
    alert(`Instruções de recuperação de senha enviadas com sucesso para o e-mail: ${email}`);
  };

  return (
    <div className="auth-page-container">
      {/* Aqui é a estrutura de card unificado contendo o painel institucional e a tela de login */}
      <div className="auth-combined-card">
        
        {/* COLUNA ESQUERDA: Informações e Banner Institucional (Ocultado em telas pequenas) */}
        <div className="auth-left-panel">
          {/* Logo da Olympus Motors no topo */}
          <div className="auth-logo-row">
            <img className="auth-logo-img" src="/olympuslogo.png" alt="Logo Olympus Motors" />
            <span className="auth-logo-text">OLYMPUS MOTORS</span>
          </div>

          {/* Banner central da Mustang */}
          <div className="auth-banner-container">
            <img className="auth-banner-img" src="/OlympusMotors.png" alt="Olympus Motors Mustang" />
          </div>

          {/* Lista de Benefícios do portal com chevrons estilizados */}
          <ul className="auth-features-list">
            <li>
              <svg className="feature-chevron" viewBox="0 0 24 24" fill="none" stroke="#e63946" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
              <span><strong>Performance</strong> — Veículos de alta performance</span>
            </li>
            <li>
              <svg className="feature-chevron" viewBox="0 0 24 24" fill="none" stroke="#e63946" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
              <span><strong>Exclusividade</strong> — Só aqui você encontra os melhores carros e com os melhores preços</span>
            </li>
            <li>
              <svg className="feature-chevron" viewBox="0 0 24 24" fill="none" stroke="#e63946" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
              <span><strong>Segurança</strong> — Dados protegidos e criptografados</span>
            </li>
          </ul>

          {/* Rodapé de Copyright */}
          <div className="auth-footer-copyright">
            © 2026 Olympus Motors. Todos os direitos reservados.
          </div>
        </div>

        {/* COLUNA DIREITA: Área dos formulários de Login/Registro */}
        <div className="auth-right-panel">
          <div className="auth-right-content">
            
            {/* Chaveador visual premium para selecionar Modo Demo / API Online */}
            <div className="demo-mode-selector">
              <span className="selector-label">Conexão:</span>
              <div className="toggle-container">
                <button 
                  type="button" 
                  className={`toggle-btn ${modoDemo ? 'active' : ''}`}
                  onClick={() => setModoDemo(true)}
                  title="Simula o login/registro localmente sem precisar do backend rodando"
                >
                  Modo Demo
                </button>
                <button 
                  type="button" 
                  className={`toggle-btn ${!modoDemo ? 'active' : ''}`}
                  onClick={() => setModoDemo(false)}
                  title="Conecta diretamente com a API Spring Boot (localhost:8080)"
                >
                  API Online
                </button>
              </div>
            </div>

            {/* Cabeçalho do formulário */}
            <div className="auth-card-header">
              <div className="header-badge-row">
                <span className="header-badge-line"></span>
                <span className="header-badge-text">
                  {isLogin ? 'ACESSO RESTRITO' : 'NOVO PILOTO'}
                </span>
              </div>
              <h1 className="auth-title">
                {isLogin ? 'Entre na sua conta' : 'Criar sua conta'}
              </h1>
              <p className="auth-subtitle">
                {isLogin 
                  ? 'Acesse o painel exclusivo Olympus Motors' 
                  : 'Junte-se à frota exclusiva Olympus Motors'}
              </p>
            </div>

            {/* Mensagem de Erro Geral, caso exista */}
            {erroGeral && (
              <div className="auth-alert error" role="alert">
                <svg className="alert-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="8" x2="12" y2="12"></line>
                  <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
                <span>{erroGeral}</span>
              </div>
            )}

            {/* Mensagem informativa sobre o Modo Demo ativo */}
            {modoDemo && isLogin && (
              <div className="auth-alert info" role="alert">
                <svg className="alert-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="16" x2="12" y2="12"></line>
                  <line x1="12" y1="8" x2="12.01" y2="8"></line>
                </svg>
                <div>
                  <strong>Modo Demo Ativo:</strong> Credenciais pré-preenchidas com perfil de Administrador para teste fácil.
                </div>
              </div>
            )}

            {/* Formulário HTML5 semântico */}
            <form onSubmit={handleSubmit} className="auth-form" noValidate>
              
              {/* CAMPO: NOME COMPLETO (Apenas na tela de registro) */}
              {!isLogin && (
                <div className={`auth-input-group ${erros.nomeCompleto ? 'has-error' : ''}`}>
                  <label htmlFor="nomeCompleto">NOME COMPLETO</label>
                  <div className="input-wrapper">
                    <span className="input-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                      </svg>
                    </span>
                    <input
                      id="nomeCompleto"
                      type="text"
                      placeholder="Beathryce Aurora"
                      value={nomeCompleto}
                      onChange={(e) => setNomeCompleto(e.target.value)}
                      required
                      aria-invalid={!!erros.nomeCompleto}
                      aria-describedby={erros.nomeCompleto ? 'err-nome' : undefined}
                    />
                  </div>
                  {erros.nomeCompleto && (
                    <span className="error-message" id="err-nome">{erros.nomeCompleto}</span>
                  )}
                </div>
              )}

              {/* CAMPO: E-MAIL (Presente em ambos) */}
              <div className={`auth-input-group ${erros.email ? 'has-error' : ''}`}>
                <label htmlFor="email">E-MAIL</label>
                <div className="input-wrapper">
                  <span className="input-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                      <polyline points="22,6 12,13 2,6"></polyline>
                    </svg>
                  </span>
                  <input
                    id="email"
                    type="email"
                    placeholder="seu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    aria-invalid={!!erros.email}
                    aria-describedby={erros.email ? 'err-email' : undefined}
                  />
                </div>
                {erros.email && (
                  <span className="error-message" id="err-email">{erros.email}</span>
                )}
              </div>

              {/* CAMPO: SENHA (Presente em ambos) */}
              <div className={`auth-input-group ${erros.senha ? 'has-error' : ''}`}>
                <label htmlFor="senha">SENHA</label>
                <div className="input-wrapper">
                  <span className="input-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                  </span>
                  <input
                    id="senha"
                    type={showSenha ? 'text' : 'password'}
                    placeholder="••••••••"
                    value={senha}
                    onChange={(e) => setSenha(e.target.value)}
                    required
                    aria-invalid={!!erros.senha}
                    aria-describedby={erros.senha ? 'err-senha' : undefined}
                  />
                  <button
                    type="button"
                    className="password-toggle-btn"
                    onClick={() => setShowSenha(!showSenha)}
                    aria-label={showSenha ? 'Ocultar senha' : 'Exibir senha'}
                  >
                    {showSenha ? (
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                        <line x1="1" y1="1" x2="23" y2="23"></line>
                      </svg>
                    ) : (
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                      </svg>
                    )}
                  </button>
                </div>
                {erros.senha && (
                  <span className="error-message" id="err-senha">{erros.senha}</span>
                )}
              </div>

              {/* CAMPO: CONFIRMAR SENHA (Apenas na tela de registro) */}
              {!isLogin && (
                <div className={`auth-input-group ${erros.confirmarSenha ? 'has-error' : ''}`}>
                  <label htmlFor="confirmarSenha">CONFIRMAR SENHA</label>
                  <div className="input-wrapper">
                    <span className="input-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                      </svg>
                    </span>
                    <input
                      id="confirmarSenha"
                      type={showConfirmarSenha ? 'text' : 'password'}
                      placeholder="••••••••"
                      value={confirmarSenha}
                      onChange={(e) => setConfirmarSenha(e.target.value)}
                      required
                      aria-invalid={!!erros.confirmarSenha}
                      aria-describedby={erros.confirmarSenha ? 'err-confsenha' : undefined}
                    />
                    <button
                      type="button"
                      className="password-toggle-btn"
                      onClick={() => setShowConfirmarSenha(!showConfirmarSenha)}
                      aria-label={showConfirmarSenha ? 'Ocultar senha' : 'Exibir senha'}
                    >
                      {showConfirmarSenha ? (
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                          <line x1="1" y1="1" x2="23" y2="23"></line>
                        </svg>
                      ) : (
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                          <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                      )}
                    </button>
                  </div>
                  {erros.confirmarSenha && (
                    <span className="error-message" id="err-confsenha">{erros.confirmarSenha}</span>
                  )}
                </div>
              )}

              {/* CAMPO: SELECIONAR CARGO/PERMISSÃO (Apenas na tela de registro para facilitar testes de permissão no backend) */}
              {!isLogin && (
                <div className="auth-input-group">
                  <label htmlFor="cargo">CARGO DO USUÁRIO</label>
                  <div className="input-wrapper">
                    <span className="input-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                      </svg>
                    </span>
                    <select
                      id="cargo"
                      value={cargo}
                      onChange={(e) => setCargo(e.target.value)}
                    >
                      <option value="COMUM">COMUM (Apenas Visualizar Carros)</option>
                      <option value="ADMIN">ADMIN (Controle Total - CRUD)</option>
                    </select>
                  </div>
                </div>
              )}

              {/* ÁREA DE AÇÕES EXTRAS (Lembrar-me, esqueci a senha, termos de privacidade) */}
              {isLogin ? (
                <div className="auth-actions-row">
                  <label className="auth-checkbox-label">
                    <input
                      type="checkbox"
                      checked={lembrarMe}
                      onChange={(e) => setLembrarMe(e.target.checked)}
                    />
                    <span className="custom-checkbox"></span>
                    <span className="checkbox-text">Lembrar-me</span>
                  </label>
                  
                  <button 
                    type="button" 
                    className="btn-link"
                    onClick={handleEsqueciSenha}
                  >
                    Esqueci a senha
                  </button>
                </div>
              ) : (
                <div className={`auth-actions-row flex-column ${erros.termosAceitos ? 'has-error' : ''}`}>
                  <label className="auth-checkbox-label align-start">
                    <input
                      type="checkbox"
                      checked={termosAceitos}
                      onChange={(e) => setTermosAceitos(e.target.checked)}
                      required
                    />
                    <span className="custom-checkbox mt-2"></span>
                    <span className="checkbox-text font-small">
                      Concordo com os <a href="#termos" className="red-link">Termos de Uso</a> e <a href="#privacidade" className="red-link">Política de Privacidade</a>
                    </span>
                  </label>
                  {erros.termosAceitos && (
                    <span className="error-message mt-2">{erros.termosAceitos}</span>
                  )}
                </div>
              )}

              {/* BOTÃO SUBMIT (Entrar / Criar Conta) */}
              <button
                type="submit"
                className="auth-submit-btn"
                disabled={loading}
              >
                {loading ? (
                  <span className="spinner"></span>
                ) : isLogin ? (
                  <>
                    ACESSAR 
                    <svg className="btn-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <line x1="5" y1="12" x2="19" y2="12"></line>
                      <polyline points="12 5 19 12 12 19"></polyline>
                    </svg>
                  </>
                ) : (
                  <>
                    CRIAR CONTA
                    <svg className="btn-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <line x1="5" y1="12" x2="19" y2="12"></line>
                      <polyline points="12 5 19 12 12 19"></polyline>
                    </svg>
                  </>
                )}
              </button>

            </form>

            {/* Alternador de visualização entre Login e Registro */}
            <div className="auth-toggle-view-footer">
              {isLogin ? (
                <p>
                  Não tem uma conta?{' '}
                  <button type="button" className="red-link-btn" onClick={alternarModo}>
                    Criar conta
                  </button>
                </p>
              ) : (
                <p>
                  Já tem uma conta?{' '}
                  <button type="button" className="red-link-btn" onClick={alternarModo}>
                    Entrar
                  </button>
                </p>
              )}
            </div>

          </div>
        </div>

      </div>
    </div>
  );
}
