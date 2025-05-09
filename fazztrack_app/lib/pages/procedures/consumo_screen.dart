import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:flutter/material.dart';

class ConsumoScreen extends StatefulWidget {
  const ConsumoScreen({super.key});

  @override
  State<ConsumoScreen> createState() => _ConsumoScreenState();
}

class _ConsumoScreenState extends State<ConsumoScreen> {
  double balance = 0.0;
  void _onClientSelected(String client) {
    setState(() {
      // Update balance based on selected client
      balance = 0.0; // This would be replaced with actual balance fetching
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SaldoClienteWidget(
            balance: balance,
            onClientSelected: _onClientSelected,
          ),
        ],
      ),
    );
  }
}
