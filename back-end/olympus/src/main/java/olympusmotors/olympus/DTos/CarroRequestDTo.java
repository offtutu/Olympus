package olympusmotors.olympus.DTos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor 
// Essa classe apenas manda o nescessario e o essencial para o front.
public class CarroRequestDTo {
    private Integer codigo;
    private String nome;
    private String marca;
    private String modelo;
    private Integer ano;
}
