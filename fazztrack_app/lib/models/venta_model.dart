// Modelo de Venta para la aplicación Flutter
class VentaModel {
  final String? id;
  final int idEstudiante;
  final int idProducto;
  final DateTime? fechaTransaccion;
  final int idBar;
  final int nProductos;

  VentaModel({
    this.id,
    required this.idEstudiante,
    required this.idProducto,
    this.fechaTransaccion,
    required this.idBar,
    required this.nProductos,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    return VentaModel(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      idProducto: json['id_producto'],
      fechaTransaccion:
          json['fecha_transaccion'] != null
              ? DateTime.parse(json['fecha_transaccion'])
              : null,
      idBar: json['id_bar'],
      nProductos: json['n_productos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': idEstudiante,
      'id_producto': idProducto,
      'fecha_transaccion': fechaTransaccion?.toIso8601String(),
      'id_bar': idBar,
      'n_productos': nProductos,
    };
  }
}
