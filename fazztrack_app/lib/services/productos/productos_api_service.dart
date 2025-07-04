import 'dart:convert';
import 'package:fazztrack_app/models/producto_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class ProductosApiService {
  final ApiService _apiService;

  ProductosApiService() : _apiService = ApiService();
  Future<List<ProductoModel>> searchProductosByName(
    String query,
    String barId,
  ) async {
    try {
      await Future.delayed(const Duration(microseconds: 400));
      final selectedBarId = barId;
      String searchUrl =
          '${API.productos}/search?nombre=$query&idBar=$selectedBarId';

      final response = await _apiService.get(searchUrl);
      final data = jsonDecode(response.body) as List;
      return data.map((json) => ProductoModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductoModel>> getAllProductos() async {
    try {
      final response = await _apiService.get(API.productos);
      final data = jsonDecode(response.body) as List;
      return data.map((json) => ProductoModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProductoModel?> getProductById(String id) async {
    try {
      final response = await _apiService.get('${API.productos}/$id');
      final data = jsonDecode(response.body);
      return ProductoModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<ProductoModel> createProducto(ProductoModel producto) async {
    try {
      final productoData = producto.toJson();
      productoData.remove('id');
      final response = await _apiService.post(API.productos, productoData);
      final data = jsonDecode(response.body);
      return ProductoModel.fromJson(data);
    } catch (e) {
      throw Exception('Error creating producto: $e');
    }
  }

  Future<ProductoModel> updateProducto(
    String id,
    ProductoModel producto,
  ) async {
    try {
      final response = await _apiService.patch(
        '${API.productos}/$id',
        producto.toJson(),
      );
      final data = jsonDecode(response.body);
      return ProductoModel.fromJson(data);
    } catch (e) {
      throw Exception('Error updating producto: $e');
    }
  }

  Future<void> deleteProducto(String id) async {
    try {
      await _apiService.delete('${API.productos}/$id');
    } catch (e) {
      throw Exception('Error deleting producto: $e');
    }
  }
}
