class BarModel {
  final String id;
  final String nombre;

  BarModel({required this.id, required this.nombre});

  factory BarModel.fromJson(Map<String, dynamic> json) {
    return BarModel(id: json['id'] as String, nombre: json['nombre'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }

  static List<BarModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => BarModel.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<BarModel> models) {
    return models.map((model) => model.toJson()).toList();
  }
}
