import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:flutter/material.dart';

class AbonoScreen extends StatefulWidget {
  const AbonoScreen({super.key});

  @override
  State<AbonoScreen> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreen> {
  String selectedClient = 'Cliente 1';
  double balance = 500.00;

  final List<String> clients = [
    'Cliente 1',
    'Cliente 2',
    'Cliente 3',
    'Cliente 4',
    'Cliente 5',
    'Cliente 6',
    'Cliente 7',
    'Cliente 8',
    'Cliente 9',
    'Cliente 10',
  ];

  void _onClientSelected(String client) {
    setState(() {
      selectedClient = client;
      balance = client == 'Cliente 2' ? -350.00 : 500.00;
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
            clients: clients,
            initialClient: selectedClient,
            balance: balance,
            onClientSelected: _onClientSelected,
          ),
        ],
      ),
    );
  }
}
