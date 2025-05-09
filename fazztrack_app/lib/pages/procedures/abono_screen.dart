import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:flutter/material.dart';

class AbonoScreen extends StatefulWidget {
  const AbonoScreen({super.key});

  @override
  State<AbonoScreen> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [SaldoClienteWidget()],
      ),
    );
  }
}
