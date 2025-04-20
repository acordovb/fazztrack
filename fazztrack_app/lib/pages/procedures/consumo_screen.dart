import 'package:fazztrack_app/common/colors.dart';
import 'package:flutter/material.dart';

class ConsumoScreen extends StatelessWidget {
  const ConsumoScreen({super.key});

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
              Icons.attach_money,
              size: 80,
              color: AppColors.primaryTurquoise,
            ),
            SizedBox(height: 20),
            Text(
              'Página de Transacción',
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
