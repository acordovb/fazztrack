import 'package:flutter/material.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(producto.categoria),
                      color: AppColors.primaryDarkBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          producto.categoria,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primaryDarkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 12),
                const Divider(color: AppColors.primaryTurquoise, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null) ...[
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryTurquoise,
                          backgroundColor: AppColors.card,
                          side: const BorderSide(
                            color: AppColors.primaryTurquoise,
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (onDelete != null) ...[
                      ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.card,
                          side: const BorderSide(color: AppColors.error),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'bebidas':
      case 'bebida':
        return Icons.local_drink;
      case 'comida':
      case 'comidas':
        return Icons.restaurant;
      case 'snacks':
      case 'snack':
        return Icons.cookie;
      case 'postres':
      case 'postre':
        return Icons.cake;
      case 'alcohol':
      case 'alcoholicas':
        return Icons.wine_bar;
      case 'cerveza':
      case 'cervezas':
        return Icons.sports_bar;
      case 'cafeteria':
      case 'cafe':
        return Icons.local_cafe;
      default:
        return Icons.inventory;
    }
  }
}
