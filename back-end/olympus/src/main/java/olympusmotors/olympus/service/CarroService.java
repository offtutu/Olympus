package olympusmotors.olympus.service;

import java.util.List;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import olympusmotors.olympus.service.exceptions.CarroDuplicado;
import olympusmotors.olympus.service.exceptions.CarroNaoEncontrado;
import olympusmotors.olympus.service.exceptions.CodigoNaoEncontrado;
import olympusmotors.olympus.service.exceptions.Validacao;
import olympusmotors.olympus.modules.Carro;
import olympusmotors.olympus.modules.CarroRepository;

// Aqui é uma declaração que essa classe desse pacote e uma camada de service.
@Service
// Aqui é uma anotação da ferramenta Lombok para poder agilizar o projeto.
@RequiredArgsConstructor
public class CarroService {

    private final CarroRepository repository;

    // Aqui busca todos os carros registrados no vbanco de dados via CarroRepository.
    public List<Carro> procurarTodos() {
        return repository.findAll();
    }

    // Aqui ele faz a mesma coisa que o "procurarPorId", so que puxa direto pelo codigo do carro.
    public Carro procurarPorCodigo(Integer codigo) {
        return repository.findByCodigo(codigo)
                .orElseThrow(() -> new CodigoNaoEncontrado(codigo));
    }

    // Aqui busca um carro especifico usando o id do carro.
    public Carro procurarPorId(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new CarroNaoEncontrado(id));
    }

    // Aqui salva um carro no banco de dados depois de validar os dados inseridos.
    public Carro salvar(Carro carro) {
        if (carro == null) {
            throw new Validacao("Carro", "Os dados do carro não podem estar vazios");
        }

        validarNumero("Codigo", carro.getCodigo());
        validar("Nome", carro.getNome());
        validar("Modelo", carro.getModelo());
        validar("Marca", carro.getMarca());
        validarNumero("Ano", carro.getAno());
        verificarCodigo(carro);

        return repository.save(carro);
    }

    // Aqui verifica os campos de texto e retorna uma exceção se estiverem invalidos.
    private void validar(String campo, String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            throw new Validacao(campo, "Esse campo não pode estar vazio");
        }
    }

    // Aqui verifica os campos numericos e retorna uma exceção se estiverem invalidos.
    private void validarNumero(String campo, Integer valor) {
        if (valor == null) {
            throw new Validacao(campo, "Esse campo não pode estar vazio");
        }
        if (valor <= 0) {
            throw new Validacao(campo, "Esse campo precisa ser maior que zero");
        }
    }

    // Aqui verifica se já existe outro carro com o mesmo codigo inserido.
    private void verificarCodigo(Carro carro) {
        repository.findByCodigo(carro.getCodigo())
                .filter(carroExistente -> !carroExistente.getId().equals(carro.getId()))
                .ifPresent(carroExistente -> {
                    throw new CarroDuplicado(carro.getCodigo());
                });
    }

    // Aqui é um sistema de atualização, que utiliza as mesmas funcionalidades do sistema que salva os carros, só que ele foi adapatado para salvar carros já criados dentro do banco de dados.
    public Carro atualizar(Long id, Carro carro) {
        if (id == null) {
            throw new Validacao("ID", "O ID do carro não pode estar vazio");
        }
        if (carro == null) {
            throw new Validacao("Carro", "Os dados do carro não podem estar vazios");
        }

       procurarPorId(id);
       carro.setId(id);

        validarNumero("Codigo", carro.getCodigo());
        validar("Nome", carro.getNome());
        validar("Modelo", carro.getModelo());
        validar("Marca", carro.getMarca());
        validarNumero("Ano", carro.getAno());
        verificarCodigo(carro);

        return repository.save(carro);
    }

    // Aqui exclui um carro do banco de dados pelo id do carro.
    public boolean deleteById(Long id) {
        if (!repository.existsById(id)) {
            throw new CarroNaoEncontrado(id);
        }

        repository.deleteById(id);
        return true;
    }
}
