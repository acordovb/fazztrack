import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/pages/admin/student_admin_screen.dart';
import 'package:fazztrack_app/pages/admin/product_admin_screen.dart';
import 'package:fazztrack_app/pages/admin/store_admin_screen.dart';
import 'package:fazztrack_app/pages/admin/transaction_admin_screen.dart';
import 'package:flutter/material.dart';

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                // Determinar cuántas columnas usar basado en el ancho de pantalla
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 500) {
                  crossAxisCount = 2;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: [
                    _buildAdminCard(
                      context,
                      icon: Icons.school,
                      title: 'Estudiantes',
                      subtitle: 'Gestionar estudiantes\ny usuarios',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentAdminScreen(),
                            ),
                          ),
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Transacciones',
                      subtitle: 'Editar ventas\ny abonos',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const TransactionAdminScreen(),
                            ),
                          ),
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.inventory,
                      title: 'Productos',
                      subtitle: 'Administrar inventario\ny productos',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductAdminScreen(),
                            ),
                          ),
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.store,
                      title: 'Locales',
                      subtitle: 'Gestionar locales\ncomerciales',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoreAdminScreen(),
                            ),
                          ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundSecondary, AppColors.lightBlue],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise.withAlpha(20),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withAlpha(80),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
