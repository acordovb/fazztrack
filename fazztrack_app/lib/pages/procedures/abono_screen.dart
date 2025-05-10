import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/model/estudiante_model.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:flutter/material.dart';

class AbonoScreen extends StatefulWidget {
  const AbonoScreen({super.key});

  @override
  State<AbonoScreen> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreen> {
  EstudianteModel? _estudianteSeleccionado;
  double _balance = 0.0;
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
            onUserChange: (estudiante, balance) {
              setState(() {
                _estudianteSeleccionado = estudiante;
                _balance = balance;
              });
            },
          ),
        ],
      ),
    );
  }
}
