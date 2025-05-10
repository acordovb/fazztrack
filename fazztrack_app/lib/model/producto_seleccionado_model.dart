import 'package:fazztrack_app/model/producto_model.dart';

class ProductoSeleccionadoModel {
  final ProductoModel? producto;
  final int cantidad;

  ProductoSeleccionadoModel({this.producto, this.cantidad = 1});

  double get subtotal => (producto?.precio ?? 0) * cantidad;

  ProductoSeleccionadoModel copyWith({ProductoModel? producto, int? cantidad}) {
    return ProductoSeleccionadoModel(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
