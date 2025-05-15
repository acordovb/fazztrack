class EstudianteModel {
  final String id;
  final String nombre;
  final String? celular;
  final String? curso;
  final String? nombreRepresentante;

  EstudianteModel({
    required this.id,
    required this.nombre,
    this.celular,
    this.curso,
    this.nombreRepresentante,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'celular': celular,
    'curso': curso,
    'nombre_representante': nombreRepresentante,
  };

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'],
      nombre: json['nombre'],
      celular: json['celular'],
      curso: json['curso'],
      nombreRepresentante: json['nombre_representante'],
    );
  }

  static List<EstudianteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => EstudianteModel.fromJson(json)).toList();
  }
}
