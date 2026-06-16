/// Representa os dados de um carro recebidos do backend
class CarroDto {
  final int id;
  final int codigo;
  final String nome;
  final String marca;
  final String modelo;
  final int ano;

  CarroDto({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.marca,
    required this.modelo,
    required this.ano,
  });

  factory CarroDto.fromJson(Map<String, dynamic> json) {
    return CarroDto(
      id: json['id'] is int ? json['id'] : (json['id'] as num).toInt(),
      codigo: json['codigo'] is int ? json['codigo'] : (json['codigo'] as num).toInt(),
      nome: json['nome'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      ano: json['ano'] is int ? json['ano'] : (json['ano'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
    };
  }
}
