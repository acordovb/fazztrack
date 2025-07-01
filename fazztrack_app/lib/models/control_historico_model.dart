class ControlHistoricoModel {
  final String id;
  final String idEstudiante;
  final double totalPendienteUltMesAbono;
  final double totalPendienteUltMesVenta;

  ControlHistoricoModel({
    required this.id,
    required this.idEstudiante,
    required this.totalPendienteUltMesAbono,
    required this.totalPendienteUltMesVenta,
  });

  factory ControlHistoricoModel.fromJson(Map<String, dynamic> json) {
    return ControlHistoricoModel(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      totalPendienteUltMesAbono:
          json['total_pendiente_ult_mes_abono'].toDouble(),
      totalPendienteUltMesVenta:
          json['total_pendiente_ult_mes_venta'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_estudiante': idEstudiante,
      'total_pendiente_ult_mes_abono': totalPendienteUltMesAbono,
      'total_pendiente_ult_mes_venta': totalPendienteUltMesVenta,
    };
  }

  // ControlHistoricoModel copyWith({
  //   String? id,
  //   String? idEstudiante,
  //   double? totalPendienteUltMesAbono,
  //   double? totalPendienteUltMesVenta,
  // }) {
  //   return ControlHistoricoModel(
  //     id: id ?? this.id,
  //     idEstudiante: idEstudiante ?? this.idEstudiante,
  //     totalPendienteUltMesAbono:
  //         totalPendienteUltMesAbono ?? this.totalPendienteUltMesAbono,
  //     totalPendienteUltMesVenta:
  //         totalPendienteUltMesVenta ?? this.totalPendienteUltMesVenta,
  //   );
  // }
}
