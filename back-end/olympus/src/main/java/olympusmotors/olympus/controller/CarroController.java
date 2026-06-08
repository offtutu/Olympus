package olympusmotors.olympus.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import olympusmotors.olympus.DTos.CarroRequestDTo;
import olympusmotors.olympus.DTos.CarroResponseDTo;
import olympusmotors.olympus.service.CarroService;
import olympusmotors.olympus.modules.Carro;




// Aqui são as anotações do spring para setar esse pacote como uma camada de "RestController", onde ele recebe requisições http e retorna em json. Além de dar uma facilitada utilizando uma anotação do lombok.
@RestController
@RequestMapping("/api/carros")
@RequiredArgsConstructor


public class CarroController {
    private final CarroService service;

    // Aqui deixa o comando de "procurarTodos" do service pronto para o uso do usuario, onde o get puxa todos os carros registrados da lista e imprime eles.
    @GetMapping
    public ResponseEntity<List<CarroResponseDTo>> listar() {
        List<Carro> carros = service.procurarTodos();
        List<CarroResponseDTo> dtos = carros.stream().map(this::converteParaDTo).toList();
        return ResponseEntity.ok(dtos);
    }

    // Aqui é o comando por busca com Id, onde o get le a lista inteira e procura o carro com aquele id em especifico e imprime ele.
    @GetMapping("/{id}")
    public ResponseEntity<CarroResponseDTo> buscarPorId(@PathVariable Long id) {
        Carro carro = service.procurarPorId(id);
        return ResponseEntity.ok(converteParaDTo(carro));
    }

    // Aqui é basicamente a mesma coisa, só que com o codigo do carro, onde o get le a lista inteira e procura o carro registrado com aquele codigo.
    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<CarroResponseDTo> buscarPorCodigo(@PathVariable Integer codigo) {
        Carro carro = service.procurarPorCodigo(codigo);
        return ResponseEntity.ok(converteParaDTo(carro));
    }

    // Aqui é um sistema do comando mais complexo, onde ele puxa o sistema de save de carro lá do service, pega o json gerado pelo restController e traduz ele com o RequestBody, transformando os dados que estão registrados no json em um objeto dentro da lista.
    @PostMapping
    public ResponseEntity<CarroResponseDTo> Criar(@RequestBody CarroRequestDTo request) {
        Carro carro = converteParaCarro(request);
        Carro carroSalvo = service.salvar(carro);

        // Aqui retorna o HTTP do Status 201 como um aviso para o usuario que o recurso inserido já foi registrado no banco de dados com sucesso, além de criar um Json do carro.
        return ResponseEntity.status(HttpStatus.CREATED).body(converteParaDTo(carroSalvo));
    }

    // Aqui é a parte do comando do sistema de atualização, onde ele atualiza os dados de um carro pelo id e envia o id para o service para ele ficar ciente das modificações que ocorreu e atualizar os dados.
    @PutMapping("/{id}")
    public ResponseEntity<CarroResponseDTo> Atualizar(@PathVariable Long id, @RequestBody CarroRequestDTo request) {
        Carro carro = converteParaCarro(request);
        carro.setId(id);
        Carro carroAtualizado = service.atualizar(id, carro);
        return ResponseEntity.ok(converteParaDTo(carroAtualizado));
    }

    // Aqui é o sistema do comando de delete, onde ele pega a lista de carros e procura o carro com o id solicitado para deletar ele da lista.
    @DeleteMapping("/{id}")
        public ResponseEntity<Void> deletar(@PathVariable Long id) {
            service.deleteById(id);
            return ResponseEntity.noContent().build();
    }

    // Aqui é a integração do DTo no controller, tanto o Response e o Request, no Response ele vai converter o objeto carro em Data Transfer Object(DTo).
    private CarroResponseDTo converteParaDTo(Carro carro) {
        return new CarroResponseDTo(
            carro.getId(),
            carro.getCodigo(),
            carro.getNome(),
            carro.getMarca(),
            carro.getModelo(),
            carro.getAno()
        );
    }
    
    // O Request vai pegar o DTo que foi gerado pelo converterParaDTo e converter em carro novamente. 
    private Carro converteParaCarro(CarroRequestDTo dto) {
        return new Carro(
            dto.getCodigo(),
            dto.getNome(),
            dto.getMarca(),
            dto.getModelo(),
            dto.getAno()
        );
    }
    
}

