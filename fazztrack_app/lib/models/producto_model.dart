class ProductoModel {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final String idBar;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.idBar,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      precio: double.parse(json['precio'].toString()),
      categoria: json['categoria'],
      idBar: json['idBar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'id_bar': idBar,
    };
  }
}
