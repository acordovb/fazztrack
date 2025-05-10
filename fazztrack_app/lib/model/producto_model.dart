class ProductoModel {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final String? imagen;
  final String? descripcion;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    this.imagen,
    this.descripcion,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      precio: json['precio'].toDouble(),
      categoria: json['categoria'],
      imagen: json['imagen'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'imagen': imagen,
      'descripcion': descripcion,
    };
  }
}
