import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:flutter/material.dart';

class ProductAdminScreen extends StatelessWidget {
  const ProductAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Administración de Productos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundSecondary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory,
                size: 80,
                color: AppColors.primaryTurquoise,
              ),
              SizedBox(height: 20),
              Text(
                'Gestión de Productos',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Aquí podrás administrar el inventario de productos',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
