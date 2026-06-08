package olympusmotors.olympus.DTos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
// Esse aqui passa apenas oque o front deve saber.
public class CarroResponseDTo {
    private Long id;
    private Integer codigo;
    private String nome;
    private String marca;
    private String modelo;
    private Integer ano;
}
