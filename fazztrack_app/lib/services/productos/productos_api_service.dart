import 'package:fazztrack_app/model/producto_model.dart';
// import 'package:fazztrack_app/services/api/api_service.dart';

class ProductosApiService {
  // final ApiService _apiService = ApiService();

  Future<List<ProductoModel>> searchProductosByName(String query) async {
    try {
      // Esta función sería reemplazada por la llamada real a la API
      // Por ahora retorna datos de ejemplo
      await Future.delayed(const Duration(microseconds: 400));

      // Datos de ejemplo - en un caso real serían obtenidos de la API
      final List<Map<String, dynamic>> mockData = [
        {
          'id': '1',
          'nombre': 'Café Americano',
          'precio': 25.0,
          'categoria': 'Bebidas',
          'descripcion': 'Café negro americano',
        },
        {
          'id': '2',
          'nombre': 'Expresso',
          'precio': 30.0,
          'categoria': 'Bebidas',
          'descripcion': 'Café expresso concentrado',
        },
        {
          'id': '3',
          'nombre': 'Sandwich de Jamón',
          'precio': 45.0,
          'categoria': 'Comida',
          'descripcion': 'Sandwich con jamón, queso y lechuga',
        },
        {
          'id': '4',
          'nombre': 'Croissant',
          'precio': 35.0,
          'categoria': 'Panadería',
          'descripcion': 'Croissant recién horneado',
        },
        {
          'id': '5',
          'nombre': 'Jugo de Naranja',
          'precio': 30.0,
          'categoria': 'Bebidas',
          'descripcion': 'Jugo de naranja natural',
        },
      ];

      if (query.isEmpty) return [];

      // Filtra productos que contengan la consulta en su nombre
      final filteredData =
          mockData
              .where(
                (producto) => producto['nombre'].toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();

      return filteredData.map((json) => ProductoModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProductoModel?> getProductById(String id) async {
    try {
      // Esta función sería reemplazada por la llamada real a la API
      await Future.delayed(const Duration(milliseconds: 500));

      // Datos de ejemplo - en un caso real serían obtenidos de la API
      final Map<String, dynamic> mockData = {
        'id': id,
        'nombre': 'Producto #$id',
        'precio': 30.0 + (int.parse(id) * 5),
        'categoria': 'Categoría',
        'descripcion': 'Descripción del producto #$id',
      };

      return ProductoModel.fromJson(mockData);
    } catch (e) {
      return null;
    }
  }
}
