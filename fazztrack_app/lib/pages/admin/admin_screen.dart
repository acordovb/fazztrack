import 'package:fazztrack_app/common/constants/colors_constants.dart';
import 'package:flutter/material.dart';

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.primaryTurquoise,
            ),
            SizedBox(height: 20),
            Text(
              'Página de Administración',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
