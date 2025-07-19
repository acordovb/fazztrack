import 'package:fazztrack_app/models/producto_model.dart';

class VentaModel {
  final String? id;
  final String idEstudiante;
  final String idProducto;
  final DateTime fechaTransaccion;
  final String idBar;
  final int nProductos;
  final double total;
  final String? comentario;
  final ProductoModel? producto;

  VentaModel({
    this.id,
    required this.idEstudiante,
    required this.idProducto,
    required this.fechaTransaccion,
    required this.idBar,
    required this.nProductos,
    required this.total,
    this.comentario,
    this.producto,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    return VentaModel(
      id: json['id'],
      idEstudiante: json['id_estudiante'],
      idProducto: json['id_producto'],
      fechaTransaccion: DateTime.parse(json['fecha_transaccion']),
      idBar: json['id_bar'],
      nProductos: json['n_productos'],
      total: double.parse(json['total'].toString()),
      comentario: json['comentario'] ?? '',
      producto: ProductoModel.fromJson(json['producto'] ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estudiante': idEstudiante,
      'id_producto': idProducto,
      'fecha_transaccion': fechaTransaccion.toIso8601String(),
      'id_bar': idBar,
      'n_productos': nProductos,
      'total': total,
      'comentario': comentario,
    };
  }
}
