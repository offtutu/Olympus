package olympusmotors.olympus.modules;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


// Aqui São importações do framework para agilziar no processo de desenvolvimento.
@Entity // Aqui avisa para o spring que esse paga é uma entidade
@Table(name = "carros") // Aqui seta que meio que um link com oo banco de dados
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Carro {
    
    @Id // Aqui avisa que é uma primary key 
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Aqui avisa que o sistema de geração de caracteres do ID é do tipo IDENTITY
    // Set das variaveis que vão ser utilizadas para catalogar o carro.
    private Long id;
    private Integer codigo;
    private String nome;
    private String marca;
    private String modelo;
    private Integer ano;

    // Aqui é o comando de catalogar o carro.
    public Carro(Integer codigo, String nome, String marca, String modelo, Integer ano) {
        this.codigo = codigo;
        this.nome = nome;
        this.marca = marca;
        this.modelo = modelo;
        this.ano = ano;
    }
}
