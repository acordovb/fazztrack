import 'package:fazztrack_app/models/bar_model.dart';

class EstudianteModel {
  final String id;
  final String nombre;
  final String idBar;
  final String? celular;
  final String? curso;
  final String? nombreRepresentante;
  final BarModel? bar;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.idBar,
    this.celular,
    this.curso,
    this.nombreRepresentante,
    this.bar,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'id_bar': idBar,
    'celular': celular,
    'curso': curso,
    'nombre_representante': nombreRepresentante,
    'bar': bar?.toJson(),
  };

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'],
      nombre: json['nombre'],
      idBar: json['id_bar'],
      celular: json['celular'],
      curso: json['curso'],
      nombreRepresentante: json['nombre_representante'],
      bar: json['bar'] != null ? BarModel.fromJson(json['bar']) : null,
    );
  }

  static List<EstudianteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => EstudianteModel.fromJson(json)).toList();
  }
}
