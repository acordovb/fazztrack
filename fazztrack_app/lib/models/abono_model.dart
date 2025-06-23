class AbonoModel {
  final String? id;
  final String idEstudiante;
  final double total;
  final String tipoAbono;
  final DateTime? fechaAbono;

  AbonoModel({
    this.id,
    required this.idEstudiante,
    required this.total,
    required this.tipoAbono,
    this.fechaAbono,
  });

  factory AbonoModel.fromJson(Map<String, dynamic> json) {
    return AbonoModel(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      total: json['total']?.toDouble() ?? 0.0,
      tipoAbono: json['tipo_abono'],
      fechaAbono:
          json['fecha_abono'] != null
              ? DateTime.parse(json['fecha_abono'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': idEstudiante,
      'total': total,
      'tipo_abono': tipoAbono,
      'fecha_abono': fechaAbono?.toIso8601String(),
    };
  }
}
