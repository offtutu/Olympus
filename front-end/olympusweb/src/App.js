// Importação dos ganchos do React para gerenciar sessão e estados globais
import { useState } from 'react';
// Importação dos estilos gerais da aplicação
import './App.css';
// Importação da nova página de Autenticação (Login e Registro)
import AuthPage from './pages/Auth/AuthPage';
// Importação da página de Dashboard
import Dashboard from './pages/Dashboard';

// Aqui é a declaração do componente principal do App
function App() {
  // Estado que verifica se o usuário está devidamente logado consultando o localStorage
  const [usuarioLogado, setUsuarioLogado] = useState(() => {
    return !!localStorage.getItem('token');
  });

  // Estado que verifica se a sessão atual é do tipo Demo (Offline)
  const [modoDemoSession, setModoDemoSession] = useState(() => {
    return localStorage.getItem('modoDemo') === 'true';
  });

  // Aqui faz a tratativa do login do usuário salvando a sessão no localStorage
  const handleLogin = (token, role, isDemoMode) => {
    localStorage.setItem('token', token);
    localStorage.setItem('modoDemo', isDemoMode ? 'true' : 'false');
    
    // Salva o cargo em localStorage para futuras consultas visuais (opcional)
    localStorage.setItem('userCargo', role);
    
    setModoDemoSession(isDemoMode);
    setUsuarioLogado(true);
  };

  // Aqui faz a limpeza da sessão (Logout) do usuário no sistema
  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('modoDemo');
    localStorage.removeItem('userCargo');
    
    setModoDemoSession(false);
    setUsuarioLogado(false);
  };

  // Se o usuário não estiver logado, renderiza a tela de login/registro
  if (!usuarioLogado) {
    return <AuthPage onLogin={handleLogin} />;
  }

  // Se estiver logado, renderiza o painel principal (Dashboard)
  return (
    <Dashboard onLogout={handleLogout} defaultModoDemo={modoDemoSession} />
  );
}

export default App;
