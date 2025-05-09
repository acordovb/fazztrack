class ControlHistorico {
  final String id;
  final int idEstudiante;
  final double totalAbono;
  final double totalVenta;
  final double totalPendienteUltMesAbono;
  final double totalPendienteUltMesVenta;

  ControlHistorico({
    required this.id,
    required this.idEstudiante,
    required this.totalAbono,
    required this.totalVenta,
    required this.totalPendienteUltMesAbono,
    required this.totalPendienteUltMesVenta,
  });

  factory ControlHistorico.fromJson(Map<String, dynamic> json) {
    return ControlHistorico(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      totalAbono: json['total_abono'].toDouble(),
      totalVenta: json['total_venta'].toDouble(),
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
      'total_abono': totalAbono,
      'total_venta': totalVenta,
      'total_pendiente_ult_mes_abono': totalPendienteUltMesAbono,
      'total_pendiente_ult_mes_venta': totalPendienteUltMesVenta,
    };
  }
}
