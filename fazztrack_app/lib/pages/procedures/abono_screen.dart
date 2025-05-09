import 'package:fazztrack_app/common/constants/colors_constants.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:flutter/material.dart';

class AbonoScreen extends StatefulWidget {
  const AbonoScreen({super.key});

  @override
  State<AbonoScreen> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreen> {
  double balance = 500.00;

  void _onClientSelected(String client) {
    setState(() {
      // Set balance based on the selected student
      // For demonstration purposes, we'll set different balances based on student name
      balance = client.contains('2') ? -350.00 : 500.00;
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
