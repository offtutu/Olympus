// Aqui é um import de uma biblioteca que libera a conexão com o back-end
import axios from 'axios';

// Aqui faz a conexão com a API que tá no back-end
const API_URL = 'http://localhost:8080/api/carros';

// Aqui adiciona o interceptor do Axios para passar o token JWT que está no localStorage
axios.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    // Se o token existir e não for o token fictício do modo demo, ele é injetado no cabeçalho de todas as requisições
    if (token && token !== 'token-demo-123456') {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Aqui trouxe o comando de fazer login no backend para o front
export const fazerLogin = async (login, senha) => {
  try {
    const response = await axios.post('http://localhost:8080/api/auth/login', { login, senha });
    return response.data; // Retorna o DTO com o token JWT
  } catch (error) {
    console.error('Erro ao tentar fazer login:', error);
    throw error;
  }
};

// Aqui trouxe o comando de cadastrar um novo usuário no backend para o front
export const cadastrarUsuario = async (login, senha, cargo) => {
  try {
    const response = await axios.post('http://localhost:8080/api/auth/registrar', { login, senha, cargo });
    return response.data;
  } catch (error) {
    console.error('Erro ao cadastrar novo usuário:', error);
    throw error;
  }
};

// Aqui trouxe o comando de listar carros do back-end para o front
export const listarCarros = async () => {
    try {
        const response = await axios.get(API_URL);
        return response.data;
    } catch (error) {
        console.error('Erro ao listar os carros salvos: ', error);
        throw error;
    }
};

// Aqui trouxe o comando de criar carros onde o axios pega o metodo de post lá da API
export const criarCarro = async (carro) => {
    try {
        const response = await axios.post(API_URL, carro);
        return response.data;
    } catch (error) {
        console.error('Erro ao criar o carro: ', error);
        throw error;
    }
};

// Aqui trouxe o comando de procurar por Id onde o axios pega um dos metodos get e recebe por parametro o id do carro que ele deseja buscar
export const procurarPorId = async (id) => {
    try {
        const response = await axios.get(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error('Erro ao procurar o carro', error);
        throw error;
    }
};

// Aqui trouxe o comando de procurar por codigo onde o axios pega um dos metodos get só que com o rota de /codigo e recebe como parametro o codigo do carro
export const procurarPorCodigo = async (codigo) => {
    try {
        const response = await axios.get(`${API_URL}/codigo/${codigo}`);
        return response.data;
    } catch (error) {
        console.error('Erro ao procurar o carro', error);
        throw error;
    }
};

// Aqui trouxe o comando de atualizar carro onde o axios puxa um metodo da API de put onde recebe dois parametros, que é parametro de carro e o de id
export const atualizarCarro = async (id, carro) => {
    try {
        const response = await axios.put(`${API_URL}/${id}`, carro)
        return response.data;
    } catch (error) {
        console.error('Erro ao atualizar o carro', error);
        throw error;
    }
};

// Aqui pega o comando de remover carro onde o axios pega um metodo de delete da API e recebe por parametro o id
export const removerCarro = async (id) => {
    try{
        const response = await axios.delete(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error('Erro ao remover o carro', error);
        throw error;
    }
};