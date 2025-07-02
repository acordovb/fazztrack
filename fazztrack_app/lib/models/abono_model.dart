class AbonoModel {
  final String? id;
  final String idEstudiante;
  final double total;
  final String tipoAbono;
  final DateTime fechaAbono;
  final String? comentario;

  AbonoModel({
    this.id,
    required this.idEstudiante,
    required this.total,
    required this.tipoAbono,
    required this.fechaAbono,
    this.comentario,
  });

  factory AbonoModel.fromJson(Map<String, dynamic> json) {
    return AbonoModel(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      total: double.parse(json['total'].toString()),
      tipoAbono: json['tipo_abono'],
      fechaAbono: DateTime.parse(json['fecha_abono']),
      comentario: json['comentario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': idEstudiante,
      'total': total,
      'tipo_abono': tipoAbono,
      'fecha_abono': fechaAbono.toIso8601String(),
      'comentario': comentario,
    };
  }
}
